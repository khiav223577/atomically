# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'atomically'

require 'minitest/autorun'

case ENV['DB']
when 'mysql'
  require 'lib/mysql2_connection'
# when 'pg'
#   require 'lib/postgresql_connection'
else
  raise "no database"
end

require 'lib/patches'
require 'lib/seeds'

def in_sandbox
  ActiveRecord::Base.transaction do
    yield
    raise ActiveRecord::Rollback
  end
end
