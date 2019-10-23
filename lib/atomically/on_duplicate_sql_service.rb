# frozen_string_literal: true

class Atomically::OnDuplicateSqlService
  def initialize(klass, columns)
    @klass = klass
    @columns = columns
  end

  def mysql_quote_columns_for_plus
    return @columns.map do |column|
      quoted_column = quote_column(column)
      next "#{quoted_column} = #{quoted_column} + VALUES(#{quoted_column})"
    end
  end

  def pg_quote_columns_for_plus
    return @columns.map do |column|
      quoted_column = quote_column(column)
      next "#{quoted_column} = #{@klass.quoted_table_name}.#{quoted_column} + excluded.#{quoted_column}"
    end
  end

  private

  def quote_column(column)
    @klass.connection.quote_column_name(column)
  end
end
