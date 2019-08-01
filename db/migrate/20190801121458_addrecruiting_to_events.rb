class AddrecruitingToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :recruiting, :boolean, default: true, null: false
  end
end
