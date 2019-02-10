# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.integer :money, default: 0
    t.integer :action_point, default: 0
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
    t.string :desc, null: false, default: ''
    t.timestamps null: false
  end
end

ActiveSupport::Dependencies.autoload_paths << File.expand_path('../models/', __FILE__)

users = User.create([
  { name: 'user_with_bomb_and_water_gun', money: 100, action_point: 3 },
  { name: 'user_with_bomb', money: 200, action_point: 0 },
  { name: 'user_without_item' },
])

items = Item.create([
  { name: 'bomb', desc: 'An explosive weapon.' },
  { name: 'water gun', desc: 'A type of toy gun designed to shoot water.' },
  { name: 'flame thrower' },
])

UserItem.create([
  { user: users[0], item: items[0], count: 3, count_in_bag: 2 },
  { user: users[0], item: items[1], count: 5, count_in_bag: 5 },
  { user: users[1], item: items[0], count: 8, count_in_bag: 4 },
])
