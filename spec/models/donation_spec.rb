require "rails_helper"

RSpec.describe Donation do
  subject(:donation) { build(:donation, **attributes) }

  let(:attributes) do
    {
      amount_currency: currency,
      amount_decimals: decimals,
    }
  end

  let(:currency) { "GBP" }
  let(:decimals) { 250_00 }

  describe "validation" do
    context "with an unsupported currency" do
      let(:currency) { "ZZZ" }

      it { is_expected.not_to be_valid }
    end

    context "with a supported currency" do
      let(:currency) { "GBP" }

      it { is_expected.to be_valid }
    end

    context "with a minimum or above donation" do
      let(:decimals) { 250_00 }

      it { is_expected.to be_valid }
    end

    context "with a below-minimum donation" do
      let(:decimals) { 1_00 }

      it { is_expected.not_to be_valid }
    end
  end
end
