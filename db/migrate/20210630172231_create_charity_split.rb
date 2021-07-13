class CreateCharitySplit < ActiveRecord::Migration[6.1]
  def change
    create_table :charity_splits do |t|
      t.belongs_to :donation
      t.belongs_to :charity

      t.string :amount_currency, null: false, default: "GBP"
      t.integer :amount_decimals, null: false, default: 0

      t.timestamps
    end
  end
end
