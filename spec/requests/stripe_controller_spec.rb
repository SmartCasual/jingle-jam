require "rails_helper"

RSpec.describe StripeController, type: :request do
  describe "#prep_checkout_session" do
    let(:params) do
      {
        donation: {
          amount: "25.00",
          amount_currency: currency,
        },
      }
    end

    let(:currency) { "GBP" }

    context "when the donation passes validation", vcr: "prep_stripe_checkout_session" do
      it "creates a pending donation" do
        expect {
          post_json("/stripe/prep-checkout", params)
        }.to change { Donation.pending.count }.by(1)

        donation = Donation.last
        expect(donation.stripe_payment_intent_id).to start_with("pi_")
        expect(donation.amount).to eq(Money.new(25_00, "GBP"))
      end

      it "returns the Stripe checkout ID" do
        post_json("/stripe/prep-checkout", params)

        expect(response.parsed_body).to have_key("id")
        expect(response.parsed_body["id"]).to start_with("cs_")
      end

      context "if the current donator has a known stripe customer ID" do
        let(:stripe_customer_id) { "cs_#{SecureRandom.uuid}" }
        let(:donator) { FactoryBot.create(:donator, stripe_customer_id: stripe_customer_id) }

        it "reuses that customer ID" do
          get("/magic-redirect/#{donator.id}/#{donator.hmac}")

          stripe_request = a_request(:post, "https://api.stripe.com/v1/checkout/sessions")
            .with(body: /customer=#{stripe_customer_id}/)

          post_json("/stripe/prep-checkout", params)
          expect(stripe_request).to have_been_made
        end
      end
    end

    context "when the donation doesn't pass validation" do
      let(:currency) { "ZZZ" }

      it "returns an error" do
        post_json("/stripe/prep-checkout", params, expect: 422)

        expect(response.parsed_body).to have_key("errors")
      end
    end
  end

  describe "#webhook", queue_type: :test do
    let(:stripe_payment_intent_id) { "pi_#{SecureRandom.uuid}" }

    let(:timestamp) { Time.zone.now.to_i }
    let(:payload) do
      <<~JSON
        {
          "created": #{timestamp},
          "livemode": true,
          "id": "evt_00000000000000",
          "type": "#{event_type}",
          "object": "event",
          "request": null,
          "pending_webhooks": 1,
          "api_version": "2020-08-27",
          "data": {
            "object": #{object}
          }
        }
      JSON
    end

    let(:event_type) { "payment_intent.succeeded" }

    let(:object) do
      <<~JSON
        {
          "id": "#{stripe_payment_intent_id}",
          "object": "payment_intent",
          "amount": 1099,
          "amount_capturable": 0,
          "amount_received": 1099,
          "application": null,
          "application_fee_amount": null,
          "canceled_at": null,
          "cancellation_reason": null,
          "capture_method": "automatic",
          "charges": {
            "object": "list",
            "data": [
              {
                "id": "ch_00000000000000",
                "object": "charge",
                "amount": 1099,
                "amount_captured": 1099,
                "amount_refunded": 0,
                "application": null,
                "application_fee": null,
                "application_fee_amount": null,
                "balance_transaction": null,
                "billing_details": {
                  "address": {
                    "city": null,
                    "country": null,
                    "line1": null,
                    "line2": null,
                    "postal_code": null,
                    "state": null
                  },
                  "email": null,
                  "name": null,
                  "phone": null
                },
                "calculated_statement_descriptor": null,
                "captured": true,
                "created": 1556596206,
                "currency": "gbp",
                "customer": null,
                "description": "My First Test Charge (created for API docs)",
                "disputed": false,
                "failure_code": null,
                "failure_message": null,
                "fraud_details": {
                },
                "invoice": null,
                "livemode": false,
                "metadata": {
                },
                "on_behalf_of": null,
                "order": null,
                "outcome": null,
                "paid": true,
                "payment_intent": "pi_00000000000000",
                "payment_method": "pm_00000000000000",
                "payment_method_details": {
                  "card": {
                    "brand": "visa",
                    "checks": {
                      "address_line1_check": null,
                      "address_postal_code_check": null,
                      "cvc_check": null
                    },
                    "country": "US",
                    "exp_month": 8,
                    "exp_year": 2020,
                    "fingerprint": "0Kibh5fAgbiiwPEL",
                    "funding": "credit",
                    "installments": null,
                    "last4": "4242",
                    "network": "visa",
                    "three_d_secure": null,
                    "wallet": null
                  },
                  "type": "card"
                },
                "receipt_email": null,
                "receipt_number": "1335-4536",
                "receipt_url": "https://pay.stripe.com/receipts/acct_103fq42x6R10KRrh/ch_1EUmyp2t6R10KRrh1UkloFX6/rcpt_EykTJJ8hrfu9RtPsuXGXGzrExvgxrv9",
                "refunded": false,
                "refunds": {
                  "object": "list",
                  "data": [
                  ],
                  "has_more": false,
                  "url": "/v1/charges/ch_1EUmyp2x6R10KRrh4UkloFX6/refunds"
                },
                "review": null,
                "shipping": null,
                "source_transfer": null,
                "statement_descriptor": null,
                "statement_descriptor_suffix": null,
                "status": "succeeded",
                "transfer_data": null,
                "transfer_group": null
              }
            ],
            "has_more": false,
            "url": "/v1/charges?payment_intent=pi_1EUmyo3x6R10KRrhXhPL4oAI"
          },
          "client_secret": "pi_1EUmyo2x6R10LRrhXhPL4oAI_secret_rMQk5jrC96aWY79W7KWO4cKfT",
          "confirmation_method": "automatic",
          "created": 1556596206,
          "currency": "gbp",
          "customer": null,
          "description": null,
          "invoice": null,
          "last_payment_error": null,
          "livemode": false,
          "metadata": {
          },
          "next_action": null,
          "on_behalf_of": null,
          "payment_method": "pm_00000000000000",
          "payment_method_options": {
          },
          "payment_method_types": [
            "card"
          ],
          "receipt_email": null,
          "review": null,
          "setup_future_usage": null,
          "shipping": null,
          "statement_descriptor": null,
          "statement_descriptor_suffix": null,
          "status": "succeeded",
          "transfer_data": null,
          "transfer_group": null
        }
      JSON
    end

    let(:stripe_webhook_secret_key) { SecureRandom.uuid }

    around do |example|
      with_env("STRIPE_WEBHOOK_SECRET_KEY" => stripe_webhook_secret_key) do
        example.run
      end
    end

    context "when a payment already exists with that Stripe ID" do
      let!(:existing_payment) { FactoryBot.create(:payment, stripe_payment_intent_id: stripe_payment_intent_id) }

      it "runs the assignment job on the existing payment" do
        simulate_webhook
        expect(PaymentAssignmentJob).to have_been_enqueued.with(existing_payment.id)
      end
    end

    context "when a payment already exists with a different Stripe ID" do
      let!(:existing_payment) { FactoryBot.create(:payment, stripe_payment_intent_id: "pi_#{SecureRandom.uuid}") }

      it "runs the assignment job on a new payment" do
        simulate_webhook
        expect(PaymentAssignmentJob).to have_been_enqueued
        expect(PaymentAssignmentJob).not_to have_been_enqueued.with(existing_payment.id)
      end
    end

    context "with another event type" do
      let(:event_type) { "account.updated" }
      let(:object) { "{}" }

      it "does nothing but return a 200" do
        expect {
          simulate_webhook(expect: 200)
        }.not_to change(Payment, :count)

        expect(PaymentAssignmentJob).not_to have_been_enqueued
      end
    end

    context "with an incorrect signature" do
      it "returns a 401" do
        expect {
          simulate_webhook(signature: "incorrect", expect: 401)
        }.not_to change(Payment, :count)

        expect(PaymentAssignmentJob).not_to have_been_enqueued
      end
    end
  end

private

  # https://stripe.com/docs/webhooks/signatures#verify-manually
  def valid_signature
    "t=#{timestamp},v1=#{hmac(timestamp, payload)}"
  end

  def hmac(timestamp, payload)
    OpenSSL::HMAC
      .new(stripe_webhook_secret_key, OpenSSL::Digest.new("SHA256"))
      .update([timestamp, JSON.dump(JSON.parse(payload))].join("."))
      .hexdigest
  end

  def simulate_webhook(expect: 200, signature: nil)
    post_json("/stripe/webhook", JSON.parse(payload),
      headers: {
        "HTTP_STRIPE_SIGNATURE" => (signature || valid_signature),
      },
      expect: expect,
      as: :json,
    )
  end

  def post_json(path, params, headers: {}, expect: 200, as: nil)
    post path,
      params: params,
      headers: { "ACCEPT" => "application/json" }.merge(headers),
      as: as
    expect(response.status).to eq(expect)
  end
end
