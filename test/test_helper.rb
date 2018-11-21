require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'atomically'

require 'minitest/autorun'

case ENV['DB']
when 'mysql'
  require 'mysql2_connection'
# when 'pg'
#   require 'postgresql_connection'
else
  raise "no database"
end

require 'seeds'
