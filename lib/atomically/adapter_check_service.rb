
class Atomically::AdapterCheckService
  def initialize(klass)
    @klass = klass
  end

  def pg?
    return false if not defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    return @klass.connection.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
  end

  def mysql?
    return false if not defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
    return @klass.connection.is_a?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  end

  def makara_mysql?
    return false if not defined?(ActiveRecord::ConnectionAdapters::MakaraMysql2Adapter)
    return @klass.connection.is_a?(ActiveRecord::ConnectionAdapters::MakaraMysql2Adapter)
  end

  def makara_pg?
    return false if not defined?(ActiveRecord::ConnectionAdapters::MakaraPostgreSQLAdapter)
    return @klass.connection.is_a?(ActiveRecord::ConnectionAdapters::MakaraPostgreSQLAdapter)
  end
end
