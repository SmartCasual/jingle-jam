class AddDescriptionToGame < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :description, :text
  end
end
