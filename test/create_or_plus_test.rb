require 'test_helper'

class CreateOrPlusTest < Minitest::Test
  def setup
  end

  def test_no_record_in_database_with_one_update_column
    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], [[1, 2, 3, 4]], [:count])
      assert_equal [[1, 2, 3, 4]], UserItem.pluck(:user_id, :item_id, :count, :count_in_bag)
    end
  end

  def test_no_record_in_database_with_two_update_column
    in_sandbox do
      UserItem.atomically.create_or_plus([:user_id, :item_id, :count, :count_in_bag], [[1, 2, 3, 4]], [:count, :count_in_bag])
      assert_equal [[1, 2, 3, 4]], UserItem.pluck(:user_id, :item_id, :count, :count_in_bag)
    end
  end
end
