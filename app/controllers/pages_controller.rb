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

    # Find non-clashing timetables for selected courses
    scheduler = SemesterScheduler.new(course_ids)
    render plain: scheduler.start.inspect

    # Done
    # render plain: "works!"
  end
end
