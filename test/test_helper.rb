require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'atomically'

require 'minitest/autorun'

ActiveRecord::Base.establish_connection(
  'adapter'  => 'sqlite3',
  'database' => ':memory:',
)
require 'seeds'
