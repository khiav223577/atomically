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
        assert_equal 'unknown', new_item.name
        assert_equal 'An explosive weapon.', new_item.desc
        assert_equal @future, new_item.updated_at
      end
    end
  end

  def test_update_attribute_to_same_value
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal true, @item.atomically.update(name: 'bomb')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'bomb', new_item.name
        assert_equal 'An explosive weapon.', new_item.desc
        assert_equal @future, new_item.updated_at
      end
    end
  end

  def test_update_attribute_with_custom_from
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal false, @item.atomically.update({ name: 'unknown' }, { from: 'water gun' })

        new_item = Item.find_by(id: @item.id)
        assert_equal 'bomb', new_item.name
        assert_equal 'An explosive weapon.', new_item.desc
        assert_equal @item.updated_at, new_item.updated_at
      end
    end
  end

  def test_update_multiple_attributes
    in_sandbox do
      Timecop.freeze(@future) do
        assert_equal true, @item.atomically.update(name: 'unknown', desc: 'no description')

        new_item = Item.find_by(id: @item.id)
        assert_equal 'unknown', new_item.name
        assert_equal 'no description', new_item.desc
        assert_equal @future, new_item.updated_at
      end
    end
  end
end
