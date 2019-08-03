class AddAttendanceToParticipants < ActiveRecord::Migration[5.1]
  def change
    add_column :participants, :moneycollection, :boolean, default: false, null: false
    add_column :participants, :attendance, :boolean, default: false, null: false
  end
end
