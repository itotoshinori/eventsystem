class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :title
      t.string :place
      t.datetime :opendate
      t.time :starttime
      t.time :finishtime
      t.text :note
      t.string :placelink
      t.integer :user_id
      t.integer :money
      t.integer :capacity
	    t.integer:openmethod
	    t.boolean:held , default: true
      t.timestamps
    end
  end
end
