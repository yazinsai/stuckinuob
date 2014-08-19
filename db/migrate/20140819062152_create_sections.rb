class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string "number"
      t.string "instructor"
      t.string "notes"

      t.integer "course_id"
      t.timestamps
    end
  end
end
