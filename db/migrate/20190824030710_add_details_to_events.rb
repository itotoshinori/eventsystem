class AddDetailsToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :url, :string
    add_column :events, :urlname, :string
  end
end
