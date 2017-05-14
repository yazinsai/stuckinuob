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
      arr = time.to_a
      arr.length.times do |i|
        @timeline << arr[i]
      end
    else
      @timeline << time
    end

    @timeline
  end

  def inspect
    "Timeline: #{@timeline}"
  end

  def [](key = nil)
    @timeline[key]
  end

  def to_a
    @timeline.dup
  end

  def clash?(other)
    # does the timeline passed clash with this one?
    a = self.to_a.sort
    b = other.to_a.sort!

    # iterate
    while !a.empty? && !b.empty? do
      return true if range_overlap?(a[0], b[0])

      # remove earlier element
      a[0][0] < b[0][0] ? a.shift : b.shift
    end

    false # no clash
  end

  private

  def range_overlap?(a, b)
    # do two ranges overlap? e.g. range_overlap?([100, 150], [200, 250]) => false
    !(a.first > b.last || a.last < b.first)
  end
end
