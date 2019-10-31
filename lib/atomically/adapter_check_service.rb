
class Atomically::AdapterCheckService
  def initialize(klass)
    @klass = klass
  end

  def pg?
    possible_pg_klasses.any?{|s| @klass.connection.is_a?(s) }
  end

  def mysql?
    possible_mysql_klasses.any?{|s| @klass.connection.is_a?(s) }
  end

  private

  def possible_pg_klasses
    result = []
    result << ActiveRecord::ConnectionAdapters::PostgreSQLAdapter if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    result << ActiveRecord::ConnectionAdapters::MakaraPostgreSQLAdapter if defined?(ActiveRecord::ConnectionAdapters::MakaraPostgreSQLAdapter)
    return result
  end

  def possible_mysql_klasses
    result = []
    result << ActiveRecord::ConnectionAdapters::Mysql2Adapter if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
    result << ActiveRecord::ConnectionAdapters::MakaraMysql2Adapter if defined?(ActiveRecord::ConnectionAdapters::MakaraMysql2Adapter)
    return result
  end
end
