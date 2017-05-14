require 'test_helper'

class SemesterSchedulerTest < ActiveSupport::TestCase
  test "it validates the course_ids passed" do
    assert_raises ActiveRecord::RecordNotFound do
      SemesterScheduler.new(["hi"])
    end
  end

  test "it checks the exam dates for clashes" do
    s = SemesterScheduler.new([courses(:one).id, courses(:clash_with_one).id])
    assert_raises ArgumentError do
      s.start
    end
  end

  test "it groups course sections that have similar start and end times" do
    s = SemesterScheduler.new([courses(:repeated_sections).id])
    g = s.group_similar_sections
    
    # only one group should get created for both sections
    assert_equal 1, g[courses(:repeated_sections).id].count 
  end


  test "it finds schedules that don't clash" do
    s = SemesterScheduler.new([courses(:repeated_sections).id])
    g = s.group_similar_sections
    
    result = s.find_timetables(g)
    assert true, result.any?
  end

end
