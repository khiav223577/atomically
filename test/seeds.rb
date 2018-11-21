ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.text :serialized_attribute
  end
end

class User < ActiveRecord::Base
end
