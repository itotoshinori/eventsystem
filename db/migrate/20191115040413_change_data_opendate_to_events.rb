class ChangeDataOpendateToEvents < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :opendate, :date
  end
end
