# frozen_string_literal: true

require 'test_helper'

class CreateOrPlusTest < Minitest::Test
  def setup
  end

  def test_add_items_to_user_who_already_had_all_of_them
    user = User.find_by(name: 'user_with_bomb')
    item = Item.find_by(name: 'bomb')
    data = [[user.id, item.id, 4, 3]]

    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], data, [:count])
      assert_equal [[item.id, 12, 4]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], data, [:count, :count_in_bag])
      assert_equal [[item.id, 12, 7]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end

  def test_add_items_to_user_who_did_not_have
    user = User.find_by(name: 'user_without_item')
    item = Item.find_by(name: 'bomb')
    data = [[user.id, item.id, 4, 3]]

    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], data, [:count])
      assert_equal [[item.id, 4, 3]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], data, [:count, :count_in_bag])
      assert_equal [[item.id, 4, 3]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end

  def test_add_items_to_user_who_already_had_some_of_them
    user = User.find_by(name: 'user_with_bomb')
    item1 = Item.find_by(name: 'bomb')
    item2 = Item.find_by(name: 'water gun')
    data = [[user.id, item1.id, 4, 3], [user.id, item2.id, 10, 8]]

    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], data, [:count])
      assert_equal [[item1.id, 12, 4], [item2.id, 10, 8]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], data, [:count, :count_in_bag])
      assert_equal [[item1.id, 12, 7], [item2.id, 10, 8]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end
end
