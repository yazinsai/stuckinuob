# TimeTable is a collection of Timelines, adding features that allow for
# clash-detection.

class TimeTable
  def initialize
    @sections = []
  end

  def add_section(section)
    # If this is the first one, just add it without a fuss
    if @sections.empty?
      @sections << section
      return
    end

    # Check for clashes with existing sections
    clash?(section)
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
