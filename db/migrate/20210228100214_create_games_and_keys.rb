class CreateGamesAndKeys < ActiveRecord::Migration[6.1]
  def change
    create_table :bundle_definition_game_entries do |t|
      t.belongs_to :bundle_definition, null: false
      t.belongs_to :game, null: false
      t.monetize :price, amount: { null: true }, currency: { null: true }

      t.timestamps
    end

    create_table :games do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :keys do |t|
      t.string :code, null: false
      t.belongs_to :game, null: false
      t.belongs_to :bundle, null: true

      t.timestamps
    end

    add_belongs_to :bundles, :bundle_definition, null: false
  end
end
