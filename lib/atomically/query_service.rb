# frozen_string_literal: true

require 'activerecord-import'
require 'rails_or'

class Atomically::QueryService
  def initialize(klass, relation: nil)
    @klass = klass
    @relation = relation || @klass
  end

  def create_or_plus(columns, data, update_columns)
    @klass.import(columns, data, on_duplicate_key_update: on_duplicate_key_plus_sql(update_columns))
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
    update_sqls = update_columns.map.with_index do |column, idx|
      value = idx == 0 ? "(@change := \nCASE #{quote_column(primary_key)}\n#{raw_when_sql}\nEND)" : '@change'
      next "#{column} = #{column} + #{value}"
    end

    return query.where("(#{@klass.from(query).select('COUNT(*)').to_sql}) = ?", hash.size)
                .update_all(update_sqls.join(', '))
  end

  private

  def on_duplicate_key_plus_sql( columns)
    columns.lazy.map(&method(:quote_column)).map{|s| "#{s} = #{s} + VALUES(#{s})" }.force.join(', ')
  end

  def quote_column(column)
    @klass.connection.quote_column_name(column)
  end

  def sanitize(*args)
    @klass.sanitize(*args)
  end
end
