class AddStripeCheckoutSessionIdToDonation < ActiveRecord::Migration[6.1]
  def change
    add_column :donations, :stripe_checkout_session_id, :string
  end
end
