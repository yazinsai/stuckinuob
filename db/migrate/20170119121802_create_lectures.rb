class CreateLectures < ActiveRecord::Migration[5.0]
  def change
    create_table :lectures do |t|
      t.string :days
      t.integer :start_time
      t.integer :end_time
      t.string :room
      t.integer :section_id

      t.timestamps
    end
  end
end
