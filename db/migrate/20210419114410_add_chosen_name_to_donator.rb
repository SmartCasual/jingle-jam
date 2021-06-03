class AddChosenNameToDonator < ActiveRecord::Migration[6.1]
  def change
    add_column :donators, :chosen_name, :string
  end
end
