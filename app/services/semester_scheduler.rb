# This class is responsible for finding Timetables that don't clash
# based on the list of courses selected

class SemesterScheduler
  def initialize(course_ids)
    @courses = []

    course_ids.each do |course_id|
      @courses << Course.find(course_id)
    end
  end

  def start
    # Iterates over all sections in all courses and finds the combinations that
    # clash with one another. Stores results in @timetables
    must_have_courses
    
    if exams_clash?
      raise(ArgumentError, "The courses you picked clash on exam dates") if exams_clash?
    end
  end

  private

  def must_have_courses
    raise(ArgumentError, "No courses added") if @courses.empty?
  end

  def exams_clash?
    # do the exams for the courses clash?
    exams = {}
    @courses.each do |course|
      exams[course.exam_date] ||= []

      timeline = Timeline.new([course.exam_start, course.exam_end])
      exams[course.exam_date] << timeline
    end

    # iterate over the exam dates
    exams.keys.each do |date|
      exams[date].combination(2).each do |a, b|
        return true if a.clash? b
      end
    end

    false
  end
end
