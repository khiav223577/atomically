class User < ActiveRecord::Base
  has_many :user_items
  has_many :items, through: :user_items
end
