ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :email
    t.timestamps null: false
  end

  create_table :user_items, force: true do |t|
    t.references :user
    t.references :item
    t.integer :count, null: false, default: 0
    t.integer :count_in_bag, null: false, default: 0
    t.timestamps null: false
  end

  create_table :items, force: true do |t|
    t.string :name, null: false
    t.timestamps null: false
  end
end

class User < ActiveRecord::Base
end

class Item < ActiveRecord::Base
end

class UserItem < ActiveRecord::Base
end
