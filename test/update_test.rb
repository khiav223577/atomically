require 'test_helper'

class UpdateTest < Minitest::Test
  def setup
  end

  def test_update_attribute
    item = Item.find_by(name: 'bomb')

    in_sandbox do
      Timecop.freeze(item.updated_at + 1.day) do
        assert_equal true, item.atomically.update(name: 'bomb2')

        new_item = Item.find_by(id: item.id)
        assert_equal 'bomb2', new_item.name
        assert_equal item.updated_at + 1.day, new_item.updated_at
      end
    end
  end

  def test_update_attribute_to_same_value
    item = Item.find_by(name: 'bomb')

    in_sandbox do
      Timecop.freeze(item.updated_at + 1.day) do
        assert_equal true, item.atomically.update(name: 'bomb')

        new_item = Item.find_by(id: item.id)
        assert_equal 'bomb', new_item.name
        assert_equal item.updated_at + 1.day, new_item.updated_at
      end
    end
  end
end
