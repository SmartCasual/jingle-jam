class CreateCharity < ActiveRecord::Migration[6.1]
  def change
    create_table :charities do |t|
      t.string :name, index: true, null: false
      t.text :description

      t.timestamps
    end
  end
end
