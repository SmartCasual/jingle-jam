require "rails_helper"

require_relative "../../test/support/request_test_helpers"

RSpec.describe StripePaymentsController, type: :request do
  include RequestTestHelpers

  describe "#prep_checkout_session" do
    let(:fundraiser) { create(:fundraiser, :active) }
    let(:params) do
      {
        donation: {
          fundraiser_id: fundraiser.id,
          human_amount: "25.00",
          amount_currency: currency,
        },
        donator_email_address: "test@example.com",
      }
    end

    let(:currency) { "GBP" }

    context "when the donation passes validation", vcr: {
      cassette_name: "prep_stripe_checkout_session",
      erb: { email_address: nil },
    } do
      it "creates a pending donation" do
        expect {
          post_json("/stripe/prep-checkout", params)
        }.to change { Donation.pending.count }.by(1)

        donation = Donation.last
        expect(donation.stripe_payment_intent_id).to start_with("pi_")
        expect(donation.amount).to eq(Money.new(25_00, "GBP"))
      end

      it "returns the Stripe checkout ID" do
        response = post_json("/stripe/prep-checkout", params)

        expect(response.parsed_body).to have_key("id")
        expect(response.parsed_body["id"]).to start_with("cs_")
      end

      context "if the current donator has a known stripe customer ID" do
        let(:stripe_customer_id) { "cs_#{SecureRandom.uuid}" }
        let(:donator) { create(:donator, stripe_customer_id:) }

        it "reuses that customer ID" do
          post(donator_token_omniauth_callback_path, params: { donator_id: donator.id, token: donator.token })

          stripe_request = a_request(:post, "https://api.stripe.com/v1/checkout/sessions")
            .with(body: /customer=#{stripe_customer_id}/)

          post("/stripe/prep-checkout", params:, headers: { "ACCEPT" => "application/json" })
          expect(stripe_request).to have_been_made
        end
      end
    end

    context "when the donation doesn't pass validation" do
      let(:currency) { "ZZZ" }

      it "returns an error" do
        response = post_json("/stripe/prep-checkout", params, expect: 422)

        expect(response.parsed_body).to have_key("errors")
      end
    end
  end

  describe "#webhook" do
    let(:stripe_payment_intent_id) { "pi_#{SecureRandom.uuid}" }

    let(:timestamp) { Time.zone.now.to_i }
    let(:payload) do
      stripe_webhook_payload(
        timestamp:,
        object:,
        event_type:,
      )
    end

    let(:event_type) { "payment_intent.succeeded" }

    let(:object) do
      stripe_payment_intent_object(
        payment_intent_id: stripe_payment_intent_id,
        amount: "1000",
        currency: "gbp",
      )
    end

    let(:stripe_webhook_secret_key) { SecureRandom.uuid }

    around do |example|
      with_env("STRIPE_WEBHOOK_SECRET_KEY" => stripe_webhook_secret_key) do
        example.run
      end
    end

    before do
      allow(Payment).to receive(:create_and_assign)
    end

    it "creates and/or assigns a payment" do
      simulate_stripe_webhook(payload:, timestamp:)
      expect(Payment).to have_received(:create_and_assign)
        .with(
          amount: 1000,
          currency: "gbp",
          stripe_payment_intent_id:,
        )
    end

    context "with another event type" do
      let(:event_type) { "account.updated" }
      let(:object) { "{}" }

      it "does nothing but return a 200" do
        expect {
          simulate_stripe_webhook(payload:, timestamp:, expect: 200)
        }.not_to change(Payment, :count)

        expect(Payment).not_to have_received(:create_and_assign)
      end
    end

    context "with an incorrect signature" do
      it "returns a 401" do
        expect {
          simulate_stripe_webhook(payload:, timestamp:, signature: "incorrect", expect: 401)
        }.not_to change(Payment, :count)

        expect(Payment).not_to have_received(:create_and_assign)
      end
    end
  end
end
