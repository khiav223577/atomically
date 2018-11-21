ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :user_items, force: true do |t|
    t.references :user
    t.references :item
    t.integer :count, null: false, default: 0
    t.integer :count_in_bag, null: false, default: 0
    t.timestamps null: false
  end

  add_index :user_items, [:user_id, :item_id], unique: true

  create_table :items, force: true do |t|
    t.string :name, null: false
    t.timestamps null: false
  end
end

class User < ActiveRecord::Base
  has_many :user_items
  has_many :items, through: :user_items
end

class Item < ActiveRecord::Base
  has_many :user_items
  has_many :users, through: :user_items
end

class UserItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
end

users = User.create([
  { name: 'user_with_bomb_and_water_gun' },
  { name: 'user_with_bomb' },
  { name: 'user_without_item' },
])

items = Item.create([
  { name: 'bomb' },
  { name: 'water gun' },
  { name: 'flame thrower' },
])

user_items = UserItem.create([
  { user: users[0], item: items[0], count: 3, count_in_bag: 2 },
  { user: users[0], item: items[1], count: 5, count_in_bag: 5 },
  { user: users[1], item: items[0], count: 8, count_in_bag: 4 },
])
