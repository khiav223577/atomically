# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'atomically'

require 'minitest/autorun'

case ENV['DB']
when 'makara_mysql' ; require 'lib/makara_mysql_connection'
when 'makara_pg'    ; require 'lib/makara_pg_connection'
when 'mysql'        ; require 'lib/mysql2_connection'
when 'pg'           ; require 'lib/postgresql_connection'
else
  fail [
    'Unknown DB',
    'Please run test cases by one of the following: ',
    '- rake test DB=mysql',
    '- rake test DB=pg',
    '- rake test DB=makara_mysql',
    '- rake test DB=makara_pg',
  ].join("\n")
end

require 'lib/patches'
require 'lib/seeds'
require 'timecop'

def in_sandbox
  ActiveRecord::Base.transaction do
    yield
    fail ActiveRecord::Rollback
  end
end

def assert_queries(expected_count, event_key = 'sql.active_record')
  sqls = []
  subscriber = ActiveSupport::Notifications.subscribe(event_key) do |_, _, _, _, payload|
    sqls << "  ● #{payload[:sql]}" if payload[:sql] !~ /\A(?:BEGIN TRANSACTION|COMMIT TRANSACTION|BEGIN|COMMIT)\z/i
  end
  yield
  if expected_count != sqls.size # show all sql queries if query count doesn't equal to expected count.
    assert_equal "expect #{expected_count} queries, but have #{sqls.size}", "\n#{sqls.join("\n").gsub('"', "'")}\n"
  end
  assert_equal expected_count, sqls.size
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end
