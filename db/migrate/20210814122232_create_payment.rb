class CreatePayment < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.string :amount_currency, null: false, default: "GBP"
      t.integer :amount_decimals, null: false, default: 0

      t.belongs_to :donation, null: true

      t.string :stripe_payment_intent_id, null: false, unique: true

      t.timestamps
    end

    add_column :donations, :stripe_payment_intent_id, :string, unique: true
    remove_column :donations, :stripe_checkout_session_id

    add_column :donators, :stripe_customer_id, :string, unique: true
  end
end
