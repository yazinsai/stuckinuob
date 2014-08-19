class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string  "code"
      t.string  "title"
      t.string  "prerequisites" # JSON array
      t.integer "credits"
      t.date    "exam_date"
      t.integer "exam_start"
      t.integer "exam_end"
      t.timestamps
    end
  end
end
