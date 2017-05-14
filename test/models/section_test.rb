require 'test_helper'

class SectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "can detect clash with other sections" do
    assert_not sections(:one).clash? sections(:two)
    assert sections(:one).clash? sections(:three)
  end
end
