class Lecture < ApplicationRecord
  belongs_to :section

  def initialize
    # Make timeline for lecture
    @timeline = Timeline.new()
    days.split("").each do |i|
      offset = day_index(i) * 60 * 24 # start of day in min.
      @timeline.add( [offset + start_time, offset + end_time] )
    end
  end

  def to_timeline
    @timeline
  end

  private

  def day_index(day)
    case day
      when "U"
        0
      when "M"
        1
      when "T"
        2
      when "W"
        3
      when "H"
        4
      else
        -1
    end
  end
end
