class Lecture < ApplicationRecord
  belongs_to :section

  def initialize
  end

  def to_timeline
    # Make timeline for lecture
    @timeline = Timeline.new()
    days.split("").each do |i|
      offset = day_index(i) * 60 * 24 # start of day in min.
      @timeline.add( [offset + start_time, offset + end_time] )
    end
    
    @timeline
  end

  private

  def day_index(day)
    case day.upcase
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
        raise IndexError, "Call to day_index with invalid day (not U,M,T,W or H)"
    end
  end
end
