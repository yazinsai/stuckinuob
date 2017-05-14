require 'test_helper'

class TimelineTest < ActiveSupport::TestCase
  test "can add times to a timeline" do
    t = Timeline.new([100, 150])
    assert_equal t.to_a, [[100, 150]] 
  end

  test "can add a timeline to a timeline" do
    t1 = Timeline.new([100, 150])
    t2 = Timeline.new([200, 250])
    assert_nothing_raised { t1.add t2 }
  end

	test "clash works with non-clashing timeline" do
    t1 = Timeline.new [660, 710]
    t1.add [720, 800]
    t2 = Timeline.new [400, 490]
    assert_not t1.clash?(t2)
  end

  test "clash detects clashing timelines" do
    t1 = Timeline.new [660, 710]
    t1.add [720, 820]
    t2 = Timeline.new [700, 750]
    assert t1.clash?(t2)
  end
end

