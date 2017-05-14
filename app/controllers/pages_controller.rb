class PagesController < ApplicationController
  def index
    @courses = Course.all
    render "index"
  end

  def check
    # Make sure we've got at least the courses specified
    params.require(:courses)
    course_ids = params[:courses]
    
    # TODO: Validate course_ids

    # Start a check
    checker = CheckService.new(course_ids)
    checker.start

    # Done
    render plain: "works!"
  end
end
