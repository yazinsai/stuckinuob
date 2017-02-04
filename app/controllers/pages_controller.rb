class PagesController < ApplicationController
  def index
    @courses = Course.all
    render "index"
  end

  def check
    # Make sure we've got at least the courses specified
    params.require(:courses)
    course_ids = params[:courses]

    # Start a check
    checker = CheckService.new({ courses: course_ids })

    # Done
    render text: "works!"
  end
end
