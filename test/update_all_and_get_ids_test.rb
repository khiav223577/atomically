require 'test_helper'

class UpdateAllAndGetIdsTest < Minitest::Test
  def setup
  end

  def test_update_all_and_get_ids_on_klass
    in_sandbox do
      assert_equal [3, 2, 1], Item.atomically.update_all_and_get_ids(name: '')
      assert_equal ['', '', ''], Item.pluck(:name)
    end
  end

  def test_update_all_on_relation
    in_sandbox do
      assert_equal [3, 1], Item.where(id: [1, 3]).atomically.update_all_and_get_ids(name: '')
      assert_equal ['', 'water gun', ''], Item.pluck(:name)
    end
  end

  def test_update_all_on_relation_and_with_race_condition
    in_sandbox do
      assert_equal 1, Item.where(id: 1).update_all(id: -1)
      assert_equal [2], Item.where(id: [1, 2]).atomically.update_all_and_get_ids(name: '')
      assert_equal ['bomb', '', 'flame thrower'], Item.pluck(:name)
    end
  end
end
