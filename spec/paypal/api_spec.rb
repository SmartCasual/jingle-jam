require "rails_helper"

require "paypal/api"

RSpec.describe Paypal::API do
  before do
    allow(Paypal::BearerToken).to receive(:new)
      .and_return(instance_double("Paypal::BearerToken", to_s: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
  end

  describe ".create_order(params)" do
    let(:params) do
      {
        intent: "CAPTURE",
        purchase_units: [
          {
            amount: {
              currency_code: "USD",
              value: "1.00",
            },
            description: "Donation to Twitch",
          },
        ],
        application_context: {
          brand_name: "Twitch",
          landing_page: "LOGIN",
          shipping_preference: "NO_SHIPPING",
        },
      }
    end

    it "sends the correct body/headers and returns the order id" do
      stub_request(:post, "https://api.paypal.example.com/v2/checkout/orders")
        .with(
          body: params,
          headers: {
            "Content-Type": "application/json",
            Authorization: "Bearer ABCDEFGHIJKLMNOPQRSTUVWXYZ",
          },
        ).to_return(
          status: 200,
          body: { id: "PAY-1AB23456CD789012EF34GHIJ" }.to_json,
        )

      expect(described_class.create_order(params)).to eq("PAY-1AB23456CD789012EF34GHIJ")
    end
  end

  describe ".capture_payment_for_order(order_id)" do
    let(:order_id) { "PAY-1AB23456CD789012EF34GHIJ" }

    it "sends the correct body/headers" do
      stub_request(:post, "https://api.paypal.example.com/v2/checkout/orders/#{order_id}/capture")
        .with(
          body: {},
          headers: {
            "Content-Type": "application/json",
            Authorization: "Bearer ABCDEFGHIJKLMNOPQRSTUVWXYZ",
          },
        ).to_return(
          status: 200,
          body: { id: "PAY-1AB23456CD789012EF34GHIJ" }.to_json,
        )

      expect { described_class.capture_payment_for_order(order_id) }.not_to raise_error
    end
  end
end
