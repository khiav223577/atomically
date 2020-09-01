require 'test_helper'

class UpdateTest < Minitest::Test
  def setup
    @item = Item.find_by(name: 'bomb')
    @future = @item.updated_at + 1.day
  end

  def test_update_attribute
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal true, @item.atomically.update(name: 'unknown')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'unknown', @item.name
        assert_equal 'unknown', new_item.name
        assert_equal 'An explosive weapon.', @item.desc
        assert_equal 'An explosive weapon.', new_item.desc
        assert_in_delta @item.updated_at, new_item.updated_at, 1.day
      end
    end
  end

  def test_update_attribute_when_there_are_changes
    in_sandbox do
      Timecop.freeze(@future) do
        @item.desc = 'unknown weapon.'
        assert_equal true, @item.atomically.update(name: 'unknown')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'unknown', @item.name
        assert_equal 'unknown', new_item.name
        assert_equal 'unknown weapon.', @item.desc
        assert_equal 'unknown weapon.', new_item.desc
        assert_in_delta @item.updated_at, new_item.updated_at, 1.day
      end
    end
  end

  def test_update_attribute_with_race_condition
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal 1, Item.where(id: @item.id).update_all(name: 'super bomb')
        assert_equal false, @item.atomically.update(name: 'unknown')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'bomb', @item.name
        assert_equal 'super bomb', new_item.name
        assert_equal 'An explosive weapon.', @item.desc
        assert_equal 'An explosive weapon.', new_item.desc
        assert_in_delta @item.updated_at, new_item.updated_at, 0.day
      end
    end
  end

  def test_update_attribute_to_same_value
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal true, @item.atomically.update(name: 'bomb')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'bomb', @item.name
        assert_equal 'bomb', new_item.name
        assert_equal 'An explosive weapon.', @item.desc
        assert_equal 'An explosive weapon.', new_item.desc
        assert_in_delta @item.updated_at, new_item.updated_at, 1.day
      end
    end
  end

  def test_update_attribute_with_custom_from
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal false, @item.atomically.update({ name: 'unknown' }, from: 'super bomb')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'bomb', @item.name
        assert_equal 'bomb', new_item.name
        assert_equal 'An explosive weapon.', @item.desc
        assert_equal 'An explosive weapon.', new_item.desc
        assert_in_delta @item.updated_at, new_item.updated_at, 0.day
      end
    end
  end

  def test_update_attribute_with_custom_from_and_with_race_condition
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal 1, Item.where(id: @item.id).update_all(name: 'super bomb')
        assert_equal true, @item.atomically.update({ name: 'unknown' }, from: 'super bomb')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'unknown', @item.name
        assert_equal 'unknown', new_item.name
        assert_equal 'An explosive weapon.', @item.desc
        assert_equal 'An explosive weapon.', new_item.desc
        assert_in_delta @item.updated_at, new_item.updated_at, 1.day
      end
    end
  end

  def test_update_multiple_attributes
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal true, @item.atomically.update(name: 'unknown', desc: 'no description')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'unknown', @item.name
        assert_equal 'unknown', new_item.name
        assert_equal 'no description', @item.desc
        assert_equal 'no description', new_item.desc
        assert_in_delta @item.updated_at, new_item.updated_at, 1.day
      end
    end
  end
end
