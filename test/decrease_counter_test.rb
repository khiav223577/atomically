# frozen_string_literal: true

require 'test_helper'

class DecreaseCounterTest < Minitest::Test
  def setup
  end

  def test_decrease_one_column_and_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      assert_equal true, user.atomically.decrease_counter(money: 95)
      assert_equal 5, user.reload.money
    end
  end

  def test_decrease_one_column_and_not_enough
    user = User.find_by(name: 'user_with_bomb_and_water_gun')
    in_sandbox do
      assert_equal false, user.atomically.decrease_counter(money: 105)
      assert_equal 100, user.reload.money
    end
  end
end
