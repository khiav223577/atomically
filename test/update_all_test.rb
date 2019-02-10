require 'test_helper'

class UpdateAllTest < Minitest::Test
  def setup
  end

  def test_update_all_on_klass
    in_sandbox do
      assert_equal 3, Item.atomically.update_all(3, name: '')
      assert_equal ['', '', ''], Item.order(:id).pluck(:name)
    end
  end

  def test_update_all_on_relation
    in_sandbox do
      assert_equal 2, Item.where(id: [1, 2]).atomically.update_all(2, name: '')
      assert_equal ['', '', 'flame thrower'], Item.order(:id).pluck(:name)
    end
  end

  def test_update_all_on_relation_with_wrong_expected_size
    in_sandbox do
      assert_equal 0, Item.where(id: [1, 2]).atomically.update_all(3, name: '')
      assert_equal ['bomb', 'water gun', 'flame thrower'], Item.order(:id).pluck(:name)
    end
  end

  def test_update_all_on_relation_and_with_race_condition
    in_sandbox do
      assert_equal 1, Item.where(id: 1).update_all(id: -1)
      assert_equal 0, Item.where(id: [1, 2]).atomically.update_all(2, name: '')
      assert_equal ['bomb', 'water gun', 'flame thrower'], Item.order(:id).pluck(:name)
    end
  end
end
