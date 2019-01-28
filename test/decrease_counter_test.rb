# frozen_string_literal: true

require 'test_helper'

class DecreaseCounterTest < Minitest::Test
  def setup
  end

  def test_decrease_one_column_and_is_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      assert_equal true, user.atomically.decrease_counter(money: 95)
      assert_equal 5, user.reload.money
    end
  end

  def test_decrease_one_column_and_is_not_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      assert_equal false, user.atomically.decrease_counter(money: 105)
      assert_equal 100, user.reload.money
    end
  end

  def test_decrease_one_column_and_was_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      User.where(id: user.id).update_all(money: 76)
      assert_equal false, user.atomically.decrease_counter(money: 105)
      assert_equal 76, user.reload.money
    end
  end

  def test_decrease_two_columns_and_all_are_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      assert_equal true, user.atomically.decrease_counter(money: 95, action_point: 2)
      assert_equal 5, user.reload.money
      assert_equal 1, user.reload.action_point
    end
  end

  def test_decrease_two_columns_and_one_is_not_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      assert_equal false, user.atomically.decrease_counter(money: 105, action_point: 2)
      assert_equal 100, user.reload.money
      assert_equal 3, user.reload.action_point
    end

    in_sandbox do
      assert_equal false, user.atomically.decrease_counter(money: 95, action_point: 4)
      assert_equal 100, user.reload.money
      assert_equal 3, user.reload.action_point
    end
  end

  def test_decrease_two_columns_and_all_are_not_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      assert_equal false, user.atomically.decrease_counter(money: 105, action_point: 4)
      assert_equal 100, user.reload.money
      assert_equal 3, user.reload.action_point
    end
  end
end
