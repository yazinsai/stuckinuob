# Basic timeline class, essentially a 2 dimensional array
class Timeline

  def initialize(params = nil)
    # TODO: Validate array of arrays passed, with 2 pairs of items per nested array
    @timeline = []
    add(params) unless params.nil?
  end

  def add(time)
    # Adds the timeslot to itself. expects either:
    # - single slot (e.g. 1 dimensional array [900, 950])
    # - a Timeline object
    if time.is_a? Timeline
      arr = time.to_a
      arr.length.times do |i|
        @timeline << arr[i]
      end
    else
      # single dimensional array or 2D?
      if time.all? {|e| e.class == Array}
        # 2D: [[100, 150], [200, 250]...]
        time.each do |from, to|
          @timeline << [from, to]
        end
      else
        # 1D: [100, 150]
        @timeline << time
      end
    end

    @timeline.sort!
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

  def ==(other)
    # used to determine if two timelines are the same
    @timeline == other.to_a
  end

  def clash?(other)
    # does the timeline passed clash with this one?
    a = self.to_a # already sorted
    b = other.to_a.sort!

    # iterate
    while !a.empty? && !b.empty? do
      return true if range_overlap?(a[0], b[0])

      # remove earlier element
      a[0][0] < b[0][0] ? a.shift : b.shift
    end

    false # no clash
  end

  def hash
    # generates a hash from the timeline slots such that two timelines
    # with the same slots would share the same fingerprint
    @timeline.hash
  end

  private

  def range_overlap?(a, b)
    # do two ranges overlap? e.g. range_overlap?([100, 150], [200, 250]) => false
    !(a.first > b.last || a.last < b.first)
  end
end
