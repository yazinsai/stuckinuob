# TimeTable is a collection of Timelines, adding features that allow for
# clash-detection.

class TimeTable
  def initialize
    @sections = []
  end

  def add_section(section)
    # does the section clash with any of the existing sections?
    if @sections.any? && clash?(section)
      raise(ArgumentError, "Section clashes with current timetable")
    end

    @sections << section
  end

  def clash?(section)
    # Does the section passed clash with any of the sections already
    # in this timetable?
    @sections.each do |s|
      return true if s.clash? section
    end
    false
  end

  private

end
