# frozen_string_literal: true

ActiveRecord::Base.establish_connection(
  'adapter'  => 'postgresql',
  'host'     => 'postgres',
  'database' => 'github_actions_test',
  'username' => 'developer',
  'password' => 'developer_password',
  'port'     => 5432,
)
