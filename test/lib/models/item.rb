class Item < ActiveRecord::Base
  has_many :user_items
  has_many :users, through: :user_items
end
