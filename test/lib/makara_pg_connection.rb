# frozen_string_literal: true

require 'makara'

ActiveRecord::Base.establish_connection(
  'adapter'  => 'postgresql_makara',
  'database' => 'github_actions_test',
  'username' => 'developer',
  'password' => 'developer_password',
  'port'     => 5432,
  'makara'   => {
    'connections' => [
      { 'role' => 'master' },
      { 'role' => 'slave' },
      { 'role' => 'slave' },
    ],
  },
)
