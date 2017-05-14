class Section < ApplicationRecord
  has_many :lectures
  belongs_to :course

  def to_timeline
    @timeline = Timeline.new()

    lectures.each do |lecture|
      @timeline.add(lecture.to_timeline)
    end

    @timeline
  end

  def clash?(section)
    # does this section clash with the section passed?
    @timeline.clash? section.to_timeline
  end
end
