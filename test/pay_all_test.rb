require 'test_helper'

class PayAllTest < Minitest::Test
  def setup
  end

  def test_pay_two_items_but_only_have_one_of_them
    user = User.find_by(name: 'user_with_bomb')
    item1 = Item.find_by(name: 'bomb')
    item2 = Item.find_by(name: 'water gun')
    data = { item1.id => 3, item2.id => 3}

    in_sandbox do
      UserItem.where(user_id: user.id).atomically.pay_all([:count], data, primary_key: :item_id)
      assert_equal [[item1.id, 8, 4]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      UserItem.where(user_id: user.id).atomically.pay_all([:count, :count_in_bag], data, primary_key: :item_id)
      assert_equal [[item1.id, 8, 4]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end

  def test_pay_two_items_and_have_all_of_them
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    item1 = Item.find_by(name: 'bomb')
    item2 = Item.find_by(name: 'water gun')
    data = { item1.id => 2, item2.id => 2}

    in_sandbox do
      UserItem.where(user_id: user.id).atomically.pay_all([:count], data, primary_key: :item_id)
      assert_equal [[item1.id, 1, 2], [item2.id, 3, 5]], user.items.pluck(:item_id, :count, :count_in_bag)
    end

    in_sandbox do
      UserItem.where(user_id: user.id).atomically.pay_all([:count, :count_in_bag], data, primary_key: :item_id)
      assert_equal [[item1.id, 1, 0], [item2.id, 3, 3]], user.items.pluck(:item_id, :count, :count_in_bag)
    end
  end
end
