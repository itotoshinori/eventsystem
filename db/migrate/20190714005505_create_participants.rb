class CreateParticipants < ActiveRecord::Migration[5.1]
  def change
    create_table :participants do |t|
      t.integer :user_id
      t.integer :event_id
      t.boolean :cancel, default: false
      t.timestamps
    end
  end
end
