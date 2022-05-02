RSpec.describe Fundraiser, type: :model do
  describe ".open" do
    context "with an open fundraiser" do
      let!(:fundraiser) { create(:fundraiser, starts_at: 1.day.ago, ends_at: 1.day.from_now) }

      it "returns the fundraiser" do
        expect(described_class.open).to eq([fundraiser])
      end
    end

    context "with a closed fundraiser" do
      before { create(:fundraiser, starts_at: 2.days.ago, ends_at: 1.day.ago) }

      it "does not return the fundraiser" do
        expect(described_class.open).to eq([])
      end
    end

    context "with a fundraiser that hasn't started yet" do
      before { create(:fundraiser, starts_at: 1.day.from_now, ends_at: 2.days.from_now) }

      it "does not return the fundraiser" do
        expect(described_class.open).to eq([])
      end
    end

    context "with an open fundraiser that has no start date" do
      let!(:fundraiser) { create(:fundraiser, starts_at: nil, ends_at: 1.day.from_now) }

      it "returns the fundraiser" do
        expect(described_class.open).to eq([fundraiser])
      end
    end

    context "with an open fundraiser that has no end date" do
      let!(:fundraiser) { create(:fundraiser, starts_at: 1.day.ago, ends_at: nil) }

      it "returns the fundraiser" do
        expect(described_class.open).to eq([fundraiser])
      end
    end

    context "with an open fundraiser that has no start or end date" do
      let!(:fundraiser) { create(:fundraiser, starts_at: nil, ends_at: nil) }

      it "returns the fundraiser" do
        expect(described_class.open).to eq([fundraiser])
      end
    end
  end
end
