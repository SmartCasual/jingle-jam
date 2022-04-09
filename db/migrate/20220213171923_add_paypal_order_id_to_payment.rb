class AddPaypalOrderIdToPayment < ActiveRecord::Migration[7.0]
  def change
    %i[payments donations].each do |table|
      add_column table, :paypal_order_id, :string
      change_column_null table, :stripe_payment_intent_id, :true
      add_check_constraint table, "num_nonnulls(stripe_payment_intent_id, paypal_order_id) > 0"
    end
  end
end