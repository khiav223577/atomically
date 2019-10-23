require 'test_helper'

class UpdateAllAndGetIdsTest < Minitest::Test
  def setup
  end

  def test_on_klass
    in_sandbox do
      assert_equal [1, 2, 3], Item.atomically.update_all_and_get_ids(name: '')
      assert_equal ['', '', ''], Item.order('id').pluck(:name)
    end
  end

  def test_on_relation
    in_sandbox do
      assert_equal [1, 3], Item.where(id: [1, 3]).atomically.update_all_and_get_ids(name: '')
      assert_equal ['', 'water gun', ''], Item.order('id').pluck(:name)
    end
  end

  def test_none
    in_sandbox do
      assert_equal [], Item.none.atomically.update_all_and_get_ids(name: '')
      assert_equal ['bomb', 'water gun', 'flame thrower'], Item.order('id').pluck(:name)
    end
  end

  def test_where_by_name
    in_sandbox do
      assert_equal [2], Item.where(name: 'water gun').atomically.update_all_and_get_ids(name: '')
      assert_equal ['bomb', '', 'flame thrower'], Item.order('id').pluck(:name)
    end
  end

  def test_with_joins
    skip if ActiveRecord::VERSION::MAJOR < 4 # join + update_all result in ambiguous column name in Rails 3
    in_sandbox do
      assert_equal [1, 2], Item.joins(:users).atomically.update_all_and_get_ids(name: '')
      assert_equal ['', '', 'flame thrower'], Item.order('id').pluck(:name)
    end
  end

  def test_with_joins_with_raw_string_args_in_mysql
    skip if not Atomically::AdapterCheckService.new(UserItem).mysql?

    in_sandbox do
      assert_equal [1, 2], Item.joins(:users).atomically.update_all_and_get_ids('items.name = ""')
      assert_equal ['', '', 'flame thrower'], Item.order('id').pluck(:name)
    end
  end

  def test_with_joins_with_raw_string_args_in_pg
    skip if not Atomically::AdapterCheckService.new(UserItem).pg?

    in_sandbox do
      assert_equal [1, 2], Item.joins(:users).atomically.update_all_and_get_ids("name = ''")
      assert_equal ['', '', 'flame thrower'], Item.order('id').pluck(:name)
    end
  end

  def test_on_relation_and_with_race_condition
    in_sandbox do
      assert_equal 1, Item.where(id: 1).update_all(id: -1)
      assert_equal [2], Item.where(id: [1, 2]).atomically.update_all_and_get_ids(name: '')
      assert_equal ['bomb', '', 'flame thrower'], Item.order('id').pluck(:name)
    end
  end
end
