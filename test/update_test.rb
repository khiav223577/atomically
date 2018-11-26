require 'test_helper'

class UpdateTest < Minitest::Test
  def setup
  end

  def test_update_name
    item = Item.find_by(name: 'bomb')

    in_sandbox do
      assert_equal true, item.atomically.update(name: 'bomb2')
      assert_equal 'bomb2', Item.find_by(id: item.id).name
    end
  end
end
