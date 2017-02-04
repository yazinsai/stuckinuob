# See https://blog.engineyard.com/2014/keeping-your-rails-controllers-dry-with-services

class CheckService
  def initialize(params)
    course_ids = params[:courses]
    
    # Retrieve courses
    @courses = []
    course_ids.each do |course_id|
      @courses << Course.find(course_id)
    end
    #TODO: Handle course-not-found exception
end

  def start
    # Pick first two courses

  end

  private

end
