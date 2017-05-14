# This class is responsible for finding Timetables that don't clash
# based on the list of courses selected

# We compare groups instead of sections to avoid cost of repetition
Group = Struct.new :course_id, :timeline, :sections

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

    # to improve performance, we're going to group the sections that have similar
    # start/end times. this would theoretically improve performance by 250x since
    # we're making far fewer comparisons (40**5 vs 13**5)
    # groups follow the form:
    # {
    #   "course_id1" => { Group[1], Group[2], ... }
    #   "course_id2" => { ... }
    # }
    groups = group_similar_sections

    # iterate over groups, and store results in @timetables
    find_timetables(groups)

    @timetables
  end

  # private
  # should be private, but I have tests that require this to be public
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

  def group_similar_sections
    # this method iterates over the sections in each course and returns just those
    # with unique start/end times. Each unique set is assigned a group number, and
    # we map groups with sections at the end
    groups = {} # key is course.id

    @courses.each do |course|
      # group all sections by timeline
      timelines = {}
      course.sections.all.each do |section|
        t = section.to_timeline.to_a # use timeline itself as hash to overcome dups
        timelines[t] ||= []
        timelines[t] << section.id
      end

      # add to groups
      groups[course.id] ||= []
      timelines.each do |timeline, sections|
        groups[course.id] << 
          Group.new(course.id, Timeline.new(timeline), sections)
      end
    end

    groups
  end

  def find_timetables(groups_by_course)
    @timetables = []
    depth_first_search(groups_by_course, [])
    @timetables
  end

  def depth_first_search(groups_by_course, path = [])
    # recursively traverses all of the courses's groups and updates the
    # @timetables that don't clash (as an array of an array of Groups)
    if groups_by_course.empty?
      @timetables << path
      return
    end

    # top -> bottom
    # pick the first course and iterate over all timelines in that course
    first = groups_by_course.keys.first
    groups_by_course[first].each do |group|
      # does this timeline clash with our current path?
      clash = false
      path.each do |step|
        if step.timeline.clash? group.timeline
          clash = true
          break
        end
      end
      next if clash

      # go deeper
      depth_first_search(groups_by_course.except(first), path + [group])
    end
  end
end
