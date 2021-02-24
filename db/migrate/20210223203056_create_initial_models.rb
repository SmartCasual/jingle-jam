class CreateInitialModels < ActiveRecord::Migration[6.1]
  def change
    create_table :donators do |t|
      t.string :name

      t.timestamps
    end

    create_table :donations do |t|
      t.monetize :amount
      t.string :message

      t.belongs_to :donator, null: false
      t.belongs_to :bundle, null: true

      t.belongs_to :donated_by, null: true

      t.timestamps
    end

    create_table :bundles do |t|
      t.belongs_to :donator, null: true

      t.timestamps
    end

    create_table :bundle_definitions do |t|
      t.string :name, null: false
      t.monetize :price

      t.timestamps
    end
  end
end
