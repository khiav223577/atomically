require 'activerecord-import'

class Atomically::QueryService
  def initialize(klass)
    @klass = klass
  end

  def create_or_plus(columns, data, update_columns)
    @klass.import(columns, data, on_duplicate_key_update: on_duplicate_key_plus_sql(update_columns))
  end

  private

  def on_duplicate_key_plus_sql( columns)
    columns.lazy
           .map(&@klass.connection.method(:quote_column_name))
           .map{|s| "#{s} = #{s} + VALUES(#{s})" }
           .force
           .join(', ')
  end
end
