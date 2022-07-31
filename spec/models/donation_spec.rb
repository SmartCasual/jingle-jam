require "rails_helper"

RSpec.describe Donation do
  subject(:donation) { build(:donation, **attributes) }

  let(:attributes) do
    {
      amount_currency: currency,
      amount_decimals: decimals,
      donator_name: name,
    }
  end

  let(:currency) { "GBP" }
  let(:decimals) { 250_00 }

  let(:name) { nil }

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

  describe "#donator_name" do
    subject(:donation_name) { donation.donator_name }

    context "when the donator has provided a specific name for the donation" do
      let(:name) { "Donator Name" }

      it { is_expected.to eq(name) }
    end

    context "when the donator has not provided a specific name for the donation" do
      let(:name) { nil }

      it { is_expected.to eq("Anonymous") }
    end
  end

  describe "#gifted?" do
    subject(:gifted?) { donation.gifted? }

    context "when the donation is gifted" do
      before { donation.donated_by = create(:donator) }

      it { is_expected.to be(true) }
    end

    context "when the donation is not gifted" do
      it { is_expected.to be(false) }
    end
  end
end
