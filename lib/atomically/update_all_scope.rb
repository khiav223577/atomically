# frozen_string_literal: true

class UpdateAllScope
  def initialize(model: nil, relation: nil)
    @queries = []
    @relation = relation || model.class.where(id: model.id)
  end

  def where(*args)
    @relation = @relation.where(*args)
    return self
  end

  def update(query, *binding_values)
    args = binding_values.size > 0 ? [[query, *binding_values]] : [query]
    @queries << klass.send(:sanitize_sql_for_assignment, *args)
    return self
  end

  def do_query!
    return 0 if @queries.empty?
    return @relation.update_all(updates_as_string)
  end

  def updates_as_string
    @queries.join(',')
  end

  def klass
    @relation.klass
  end

  # See: https://github.com/rails/rails/blob/fc5dd0b85189811062c85520fd70de8389b55aeb/activerecord/lib/active_record/relation.rb#L315
  def to_arel
    if @relation.eager_loading?
      scope = UpdateAllScope.new(model: model, relation: @relation.apply_join_dependency)
      return scope.update(updates_as_string).to_update_manager
    end

    stmt = new_arel_update_manager

    stmt.set Arel.sql(klass.send(:sanitize_sql_for_assignment, updates_as_string))
    stmt.table(@relation.table)

    key = arel_attribute(@relation.primary_key)
    if has_join_values? || @relation.offset_value
      klass.connection.join_to_update(stmt, @relation.arel, key)
    else
      stmt.key = key
      stmt.take(@relation.arel.limit)
      stmt.order(*@relation.arel.orders)
      stmt.wheres = @relation.arel.constraints
    end

    return stmt
  end

  def to_sql
    connection = klass.connection
    sql, vars = to_sql_and_binds(connection, to_arel)
    type_casted_binds(connection, vars).each_with_index{|var, idx| sql = sql.gsub("$#{idx + 1}", connection.quote(var)) }
    return sql
  end

  private

  def new_arel_update_manager
    return Arel::UpdateManager.new(ActiveRecord::Base) if Gem::Version.new(Arel::VERSION) < Gem::Version.new('7')
    return Arel::UpdateManager.new
  end

  def has_join_values?
    return @relation.send(:has_join_values?) if @relation.respond_to?(:has_join_values?, true)
    return true if @relation.joins_values.any?
    return true if @relation.respond_to?(:left_outer_joins_values) and @relation.left_outer_joins_values.any?
    return false
  end

  def arel_attribute(name)
    return @relation.arel_attribute(name) if @relation.respond_to?(:arel_attribute)
    name = klass.attribute_alias(name) if klass.attribute_alias?(name)
    return @relation.arel_table[name]
  end

  def to_sql_and_binds(connection, arel_or_sql_string)
    return connection.send(:to_sql_and_binds, arel_or_sql_string, []) if connection.respond_to?(:to_sql_and_binds, true)
    return [arel_or_sql_string.dup.freeze, []] if !arel_or_sql_string.respond_to?(:ast)
    sql, binds = connection.visitor.accept(arel_or_sql_string.ast, connection.collector).value
    return [sql.freeze, binds || []]
  end

  def type_casted_binds(connection, binds)
    return connection.type_casted_binds(binds) if connection.respond_to?(:type_casted_binds)
    return binds.map{|column, value| connection.type_cast(value, column) } if binds.first.is_a?(Array)
    return binds.map{|attr| connection.type_cast(attr.value_for_database) }
  end
end
