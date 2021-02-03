# frozen_string_literal: true

ActiveRecord::Base.establish_connection(
  'adapter'  => 'postgresql',
  'database' => 'github_actions_test',
)
