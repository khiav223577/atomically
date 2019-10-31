# frozen_string_literal: true

require 'makara'

ActiveRecord::Base.establish_connection(
  'adapter'  => 'postgresql_makara',
  'database' => 'travis_ci_test',
  'makara'   => {
    'connections' => [
      { 'role' => 'master' },
      { 'role' => 'slave' },
      { 'role' => 'slave' },
    ],
  },
)
