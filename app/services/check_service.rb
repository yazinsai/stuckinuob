# See https://blog.engineyard.com/2014/keeping-your-rails-controllers-dry-with-services

class CheckService
  def initialize(course_ids)
    @courses = []

    # add to @courses
    course_ids.each do |course_id|
      @courses << Course.find(course_id)
    end
  end

  def start
    # Pick first two courses
    
  end

  private

end
