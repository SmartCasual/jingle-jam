require "rails_helper"

require "paypal/webhook_event"

RSpec.describe Paypal::WebhookEvent do
  subject(:event) { described_class.new(params:, request:) }

  let(:params) { {} }
  let(:request) { ActionDispatch::Request.new(request_env) }
  let(:request_env) do
    {
      "HTTP_PAYPAL_CERT_URL" => valid_cert_url,
    }
  end

  let(:common_name) { described_class::VALID_PAYPAL_CERT_CN }
  let(:cert_is_valid) { true }
  let(:date_is_valid) { true }

  let(:valid_cert_url) { "https://#{described_class::VALID_PAYPAL_CERT_HOST}/cert.pem" }

  let(:cert_cache) do
    {
      valid_cert_url => instance_double("X509Certificate",
        common_name:,
        verify: cert_is_valid,
        in_date?: date_is_valid,
      ),
    }
  end

  before do
    allow(described_class).to receive(:cert_cache)
      .and_return(cert_cache)
  end

  describe "#verify" do
    subject(:verify) { event.verify }

    context "with no request body" do
      let(:request_env) do
        { "RAW_POST_DATA" => nil }
      end

      it { is_expected.to be_falsey }
    end

    context "with an invalid cert URL" do
      let(:request_env) do
        {
          "HTTP_PAYPAL_CERT_URL" => "https://www.example.com/cert.pem",
        }
      end

      it { is_expected.to be_falsey }
    end

    context "with an invalid cert URL scheme" do
      let(:request_env) do
        {
          "HTTP_PAYPAL_CERT_URL" => "http://api.paypal.com/cert.pem",
        }
      end

      it { is_expected.to be_falsey }
    end

    context "with an invalid cert CN" do
      let(:common_name) { "www.example.com" }

      it { is_expected.to be_falsey }
    end

    context "with an invalid cert date" do
      let(:date_is_valid) { false }

      it { is_expected.to be_falsey }
    end

    context "with an invalid cert signature" do
      let(:cert_is_valid) { false }

      it { is_expected.to be_falsey }
    end
  end

  describe "#verify!" do
    subject(:verify!) { event.verify! }

    context "if #verify is false" do
      before do
        allow(event).to receive(:verify).and_return(false)
      end

      it "raises a WebhookEventVerificationFailed error" do
        expect { verify! }.to raise_error(Paypal::WebhookEventVerificationFailed)
      end
    end

    context "if #verify is true" do
      before do
        allow(event).to receive(:verify).and_return(true)
      end

      it "does not raise an error" do
        expect { verify! }.not_to raise_error
      end
    end
  end

  describe "#data" do
    subject(:data) { event.data }

    context "with params" do
      let(:params) { { foo: "bar" } }

      it "returns the params" do
        expect(data).to eq(foo: "bar")
      end
    end

    context "with no params" do
      it "returns an empty hash" do
        expect(data).to eq({})
      end
    end
  end
end
