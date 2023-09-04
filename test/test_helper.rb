# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'test_frameworks'

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
    next if payload[:sql].start_with?('PRAGMA table_info')
    next if payload[:sql] =~ /\A(?:BEGIN TRANSACTION|COMMIT TRANSACTION|BEGIN|COMMIT)\z/i

    sqls << "  ● #{payload[:sql]}"
  end
  yield
  if expected_count != sqls.size # show all sql queries if query count doesn't equal to expected count.
    assert_equal "expect #{expected_count} queries, but have #{sqls.size}", "\n#{sqls.join("\n").tr('"', "'")}\n"
  end
  assert_equal expected_count, sqls.size
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end

def assert_sqls(expected_sqls, event_key = 'sql.active_record')
  sqls = []
  subscriber = ActiveSupport::Notifications.subscribe(event_key) do |_, _, _, _, payload|
    next if payload[:sql].start_with?('PRAGMA table_info')
    next if payload[:sql] =~ /\A(?:BEGIN TRANSACTION|COMMIT TRANSACTION|BEGIN|COMMIT)\z/i

    sqls << payload[:sql]
  end
  yield

  missing_sqls = expected_sqls - sqls
  if missing_sqls.any?
    assert_equal "expect #{expected_sqls} queried, but query following sqls:\n#{sqls.join("\n").tr('"', "'")}\n", "\nmissing sqls:\n#{missing_sqls.join("\n").tr('"', "'")}\n"
  end
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end
