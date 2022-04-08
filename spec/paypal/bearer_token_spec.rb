require "rails_helper"

require "paypal/bearer_token"

RSpec.describe Paypal::BearerToken do
  describe "#expired?" do
    subject(:token) { described_class.new }

    before do
      response = instance_double(Faraday::Response, body: { expires_in: })

      allow(token).to receive(:connection)
        .and_return(instance_double(Paypal::Connection, post: response))
    end

    context "if the token has expired" do
      let(:expires_in) { -1 }

      it "returns true" do
        expect(token.expired?).to be(true)
      end
    end

    context "if the token has not expired" do
      let(:expires_in) { 3600 }

      it "returns false" do
        token.instance_variable_set(:@expires_at, 1.second.from_now)
        expect(token.expired?).to be(false)
      end
    end

    context "if `expires_in` is nil" do
      let(:expires_in) { nil }

      it "returns false" do
        expect(token.expired?).to be(false)
      end
    end
  end

  describe "#to_s" do
    subject(:token) { described_class.new }

    before do
      response = instance_double(Faraday::Response, body: { access_token: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" })

      allow(token).to receive(:connection)
        .and_return(instance_double(Paypal::Connection, post: response))
    end

    it "returns the token" do
      expect(token.to_s).to eq("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    end
  end
end
