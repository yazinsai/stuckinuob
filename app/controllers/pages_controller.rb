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
    @courses = {}
    Course.where(id: course_ids).each do |course|
      @courses[course.id] = {title: course.title, code: course.code}
    end

    # Find non-clashing timetables for selected courses
    scheduler = SemesterScheduler.new(course_ids)
    @results = scheduler.start
    render "check"

    # Done
    # render plain: "works!"
  end
end
