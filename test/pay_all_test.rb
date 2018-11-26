# frozen_string_literal: true

require 'test_helper'

class PayAllTest < Minitest::Test
  def setup
  end

  def test_pay_two_items_but_only_have_one_of_them
    user = User.find_by(name: 'user_with_bomb')
    item1 = Item.find_by(name: 'bomb')
    item2 = Item.find_by(name: 'water gun')
    data = { item1.id => 3, item2.id => 3 }

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count], primary_key: :item_id)
      assert_equal [[item1.id, 8, 4]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 8, 4]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count, :count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 8, 4]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end

  def test_pay_two_items_and_have_all_of_them
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    item1 = Item.find_by(name: 'bomb')
    item2 = Item.find_by(name: 'water gun')
    data = { item1.id => 2, item2.id => 2 }

    in_sandbox do
      assert_equal 2, user.user_items.atomically.pay_all(data, [:count], primary_key: :item_id)
      assert_equal [[item1.id, 1, 2], [item2.id, 3, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 2, user.user_items.atomically.pay_all(data, [:count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 3, 0], [item2.id, 5, 3]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 2, user.user_items.atomically.pay_all(data, [:count, :count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 1, 0], [item2.id, 3, 3]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end

  def test_pay_two_items_and_have_all_of_them_but_one_column_of_one_item_is_not_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    item1 = Item.find_by(name: 'bomb')
    item2 = Item.find_by(name: 'water gun')
    data = { item1.id => 3, item2.id => 3 }

    in_sandbox do
      assert_equal 2, user.user_items.atomically.pay_all(data, [:count], primary_key: :item_id)
      assert_equal [[item1.id, 0, 2], [item2.id, 2, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count, :count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 3, 2], [item2.id, 5, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 3, 2], [item2.id, 5, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end

  def test_pay_two_items_and_have_all_of_them_but_all_columns_of_one_item_is_not_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    item1 = Item.find_by(name: 'bomb')
    item2 = Item.find_by(name: 'water gun')
    data = { item1.id => 4, item2.id => 4 }

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count], primary_key: :item_id)
      assert_equal [[item1.id, 3, 2], [item2.id, 5, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 3, 2], [item2.id, 5, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      assert_equal 0, user.user_items.atomically.pay_all(data, [:count, :count_in_bag], primary_key: :item_id)
      assert_equal [[item1.id, 3, 2], [item2.id, 5, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end
end
