require 'test_helper'

class UpdateAllTest < Minitest::Test
  def setup
  end

  def test_update_all_on_klass
    in_sandbox do
      Item.atomically.update_all(3, name: '')
      assert_equal ['', '', ''], Item.pluck(:name)
    end
  end
end
