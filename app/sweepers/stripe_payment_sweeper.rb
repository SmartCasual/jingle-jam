class StripePaymentSweeper
  class << self
    def run
      Stripe::PaymentIntent.list.auto_paging_each do |payment_intent|
        next unless payment_intent.status == "succeeded"

        Payment.create_and_assign(
          amount: payment_intent.amount,
          currency: payment_intent.currency,
          stripe_payment_intent_id: payment_intent.id,
        )
      end
    end
  end
end
