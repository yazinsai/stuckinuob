# Basic timeline class, essentially a 2 dimensional array
# Does NOT perform high level functions like clash detection, etc.
class Timeline

  def initialize(params = nil)
    # TODO: Validate array of arrays passed, with 2 pairs of items per nested array
    @timeline = []
    add(params) unless params.nil?
  end

  def add(time)
    # Expects:
    #   - single slot (e.g. 1 dimensional array [900, 950])
    #   - Timeline
    if time.is_a? Timeline
      for i in 1..time.size
        @timeline << time.get(i-1)
      end
    else
      @timeline << time
    end

    @timeline
  end

  def inspect
    "Timeline: #{@timeline}"
  end

  def get(index = nil)
    if index.nil?
      @timeline
    else
      @timeline[index]
    end
  end

  def size
    @timeline.size
  end

  private
end
