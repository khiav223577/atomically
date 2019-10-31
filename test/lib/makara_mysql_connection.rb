# frozen_string_literal: true

require 'makara'

ActiveRecord::Base.establish_connection(
  'adapter'  => 'mysql2_makara',
  'database' => 'travis_ci_test',
  'username' => 'root',
  'makara'   => {
    'connections' => [
      { 'role' => 'master' },
      { 'role' => 'slave' },
      { 'role' => 'slave' },
    ],
  },
)
