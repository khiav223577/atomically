# frozen_string_literal: true

require 'makara'

ActiveRecord::Base.establish_connection(
  'adapter'  => 'mysql2_makara',
  'database' => 'github_actions_test',
  'username' => 'developer',
  'password' => 'developer_password',
  'host'     => '127.0.0.1',
  'port'     => 3306,
  'makara'   => {
    'connections' => [
      { 'role' => 'master' },
      { 'role' => 'slave' },
      { 'role' => 'slave' },
    ],
  },
)
