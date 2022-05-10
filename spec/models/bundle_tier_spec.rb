RSpec.describe BundleTier do
  subject(:tier) { described_class.new(**attrs) }

  let(:attrs) { {} }

  describe "#availability_text" do
    subject(:text) { tier.availability_text }

    context "with no cutoffs set" do
      it { is_expected.to be_nil }
    end

    context "with a range entirely in the future" do
      let(:attrs) do
        { starts_at: 1.day.from_now, ends_at: 2.days.from_now }
      end

      it { is_expected.to eq("Available between #{tier.send(:time, 1.day.from_now)} and #{tier.send(:time, 2.days.from_now)}") } # rubocop:disable Layout/LineLength
    end

    context "with a range entirely in the past" do
      let(:attrs) do
        { starts_at: 2.days.ago, ends_at: 1.day.ago }
      end

      it { is_expected.to eq("No longer available") }
    end

    context "with just an end date in the past" do
      let(:attrs) do
        { ends_at: 1.day.ago }
      end

      it { is_expected.to eq("No longer available") }
    end

    context "with just a start date in the future" do
      let(:attrs) do
        { starts_at: 1.day.from_now }
      end

      it { is_expected.to eq("Available from #{tier.send(:time, 1.day.from_now)}") }
    end

    context "with a start date in the past and an end date in the future" do
      let(:attrs) do
        { starts_at: 2.days.ago, ends_at: 1.day.from_now }
      end

      it { is_expected.to eq("Available until #{tier.send(:time, 1.day.from_now)}") }
    end
  end
end
