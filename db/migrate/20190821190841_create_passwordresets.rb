class CreatePasswordresets < ActiveRecord::Migration[5.1]
  def change
    create_table :passwordresets do |t|
      t.integer :user_id
      t.string :email
      t.string :passnum

      t.timestamps
    end
  end
end
