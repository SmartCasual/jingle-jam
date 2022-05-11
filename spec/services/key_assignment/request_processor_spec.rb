RSpec.describe KeyAssignment::RequestProcessor do
  describe ".ping_processor!", with_key_assignment_processor: true do
    subject(:result) { described_class.ping_processor! }

    it { is_expected.to be_truthy }
  end

  describe "on startup" do
    let(:bundle_tier) { create(:bundle_tier, :without_keys) }

    let!(:old_unfulfilled_unlocked_tier) do
      create(:donator_bundle_tier, :unfulfilled, :unlocked,
        bundle_tier:,
        updated_at: 2.hours.ago,
      )
    end

    before do
      create(:donator_bundle_tier, :fulfilled, bundle_tier:)
      create(:donator_bundle_tier, :unfulfilled, :locked, bundle_tier:)
      create(:donator_bundle_tier, :unfulfilled, :unlocked,
        bundle_tier:,
        updated_at: 1.second.ago,
      )
    end

    it "assigns keys to all unfulfilled unlocked tiers in oldest first order" do
      Key.unassigned.destroy_all

      key = create(:key, game: bundle_tier.games.first)
      expect(key.reload.donator_bundle_tier).to be_nil

      described_class.clear_all_queues

      with_key_assignment_processor do
        wait_for do
          described_class.finished_backlog?
        end
      end

      expect(key.reload.donator_bundle_tier).to eq(old_unfulfilled_unlocked_tier)
    end
  end

  describe ".queue_fulfillment(donator_bundle_tier)" do
    let(:donator_bundle_tier) { create(:donator_bundle_tier, :unfulfilled, :unlocked) }

    before do
      donator_bundle_tier.bundle_tier.games.each do |game|
        create(:key, :unassigned, game:)
      end
    end

    it "queues a fulfillment job" do
      expect(donator_bundle_tier.reload).not_to be_fulfilled

      with_key_assignment_processor do
        described_class.queue_fulfillment(donator_bundle_tier)

        wait_for do
          described_class.status_report.fetch(:queue_size).zero?
        end
      end

      expect(donator_bundle_tier.reload).to be_fulfilled
    end
  end
end
