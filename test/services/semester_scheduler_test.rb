require 'test_helper'

class SemesterSchedulerTest < ActiveSupport::TestCase
  test "it validates the course_ids passed" do
    assert_raises ActiveRecord::RecordNotFound do
      SemesterScheduler.new(["hi"])
    end
  end

  test "it checks the exam dates for clashes" do
    s = SemesterScheduler.new([courses(:one).id, courses(:two).id])
    assert_raises ArgumentError { s.start }
  end

end
