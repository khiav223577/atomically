# frozen_string_literal: true

require 'activerecord-import'
require 'rails_or'
require 'update_all_scope'
require 'atomically/on_duplicate_sql_service'
require 'atomically/adapter_check_service'
require 'atomically/patches/clear_attribute_changes' if not ActiveModel::Dirty.method_defined?(:clear_attribute_changes) and not ActiveModel::Dirty.private_method_defined?(:clear_attribute_changes)
require 'atomically/patches/none' if not ActiveRecord::Base.respond_to?(:none)
require 'atomically/patches/from' if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('4.0.0')

class Atomically::QueryService
  DEFAULT_CONFLICT_TARGETS = [:id].freeze

  def initialize(klass, relation: nil, model: nil)
    @klass = klass
    @relation = relation || @klass
    @model = model
  end

  def create_or_plus(columns, data, update_columns, conflict_target: DEFAULT_CONFLICT_TARGETS)
    @klass.import(columns, data, on_duplicate_key_update: on_duplicate_key_plus_sql(update_columns, conflict_target))
  end

  def pay_all(hash, update_columns, primary_key: :id) # { id => pay_count }
    return 0 if hash.blank?

    update_columns = update_columns.map(&method(:quote_column))

    query = hash.inject(@klass.none) do |relation, (id, pay_count)|
      condition = @relation.where(primary_key => id)
      update_columns.each{|s| condition = condition.where("#{s} >= ?", pay_count) }
      next relation.or(condition)
    end

    raw_when_sql = hash.map{|id, pay_count| "WHEN #{sanitize(id)} THEN #{sanitize(-pay_count)}" }.join("\n")
    no_var_in_sql = true if update_columns.size == 1 or adapter_check_service.pg?
    update_sqls = update_columns.map.with_index do |column, idx|
      if no_var_in_sql
        value = "(\nCASE #{quote_column(primary_key)}\n#{raw_when_sql}\nEND)"
      else
        value = idx == 0 ? "(@change := \nCASE #{quote_column(primary_key)}\n#{raw_when_sql}\nEND)" : '@change'
      end
      next "#{column} = #{column} + #{value}"
    end

    return where_all_can_be_updated(query, hash.size).update_all(update_sqls.join(', '))
  end

  def update_all(expected_size, *args)
    where_all_can_be_updated(@relation, expected_size).update_all(*args)
  end

  def update(attrs, options = {})
    from = options[:from] || :not_set
    success = update_and_return_number_of_updated_rows(attrs, from) == 1

    if success
      assign_without_changes(attrs)
      @model.send(:clear_attribute_changes, @model.changes.keys)
    end

    return success
  end

  # ==== Parameters
  #
  # * +counters+ - A Hash containing the names of the fields
  #   to update as keys and the amount to update the field by as values.
  def decrement_unsigned_counters(counters)
    result = open_update_all_scope do
      counters.each do |field, amount|
        where("#{field} >= ?", amount).update("#{field} = #{field} - ?", amount) if amount > 0
      end
    end
    return (result == 1)
  end

  def update_all_and_get_ids(*args)
    if adapter_check_service.pg?
      scope = UpdateAllScope::UpdateAllScope.new(model: @model, relation: @relation.where(''))
      scope.update(*args)
      return @klass.connection.execute("#{scope.to_sql} RETURNING id", "#{@klass} Update All").map{|s| s['id'].to_i }
    end

    ids = nil
    id_column = quote_column_with_table(:id)
    @klass.transaction do
      @relation.connection.execute('SET @ids := NULL')
      @relation.where("((@ids := CONCAT_WS(',', #{id_column}, @ids)) IS NOT NULL)").update_all(*args) # 撈出有真的被更新的 id，用逗號串在一起
      ids = @klass.from(Arel.sql('DUAL')).pluck(Arel.sql('@ids')).first
    end
    return ids.try{|s| s.split(',').map(&:to_i).uniq.sort } || [] # 將 id 從字串取出來 @id 的格式範例: '1,4,12'
  end

  private

  def adapter_check_service
    @adapter_check_service ||= Atomically::AdapterCheckService.new(@klass)
  end

  def on_duplicate_key_plus_sql(columns, conflict_target)
    service = Atomically::OnDuplicateSqlService.new(@klass, columns)
    return service.mysql_quote_columns_for_plus.join(', ') if adapter_check_service.mysql?
    return {
      conflict_target: conflict_target,
      columns: service.pg_quote_columns_for_plus.join(', '),
    }
  end

  def quote_column_with_table(column)
    "#{@klass.quoted_table_name}.#{quote_column(column)}"
  end

  def quote_column(column)
    @klass.connection.quote_column_name(column)
  end

  def sanitize(value)
    @klass.connection.quote(value)
  end

  def where_all_can_be_updated(query, expected_size)
    query.where("(#{@klass.from(query.where('')).select('COUNT(*)').to_sql}) = ?", expected_size)
  end

  def update_and_return_number_of_updated_rows(attrs, from_value)
    model = @model
    return open_update_all_scope do
      update(updated_at: Time.now)

      model.changes.each do |column, (_old_value, new_value)|
        update(column => new_value)
      end

      attrs.each do |column, value|
        old_value = (from_value == :not_set ? model[column] : from_value)
        where(column => old_value).update(column => value) if old_value != value
      end
    end
  end

  def open_update_all_scope(&block)
    return 0 if @model == nil
    scope = UpdateAllScope::UpdateAllScope.new(model: @model)
    scope.instance_exec(&block)
    return scope.do_query!
  end

  def assign_without_changes(attributes)
    @model.assign_attributes(attributes)
    @model.send(:clear_attribute_changes, attributes.keys)
  end
end
