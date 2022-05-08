require "rails_helper"
require "cancan/matchers"

require_relative "shared_examples/admin_users"
require_relative "shared_examples/private_info"
require_relative "shared_examples/public_info"

RSpec.describe PublicAbility do
  subject(:ability) { described_class.new(user) }

  let(:bundle) { create(:bundle) }
  let(:bundle_tier) { bundle.bundle_tiers.first }
  let(:charity) { build(:charity) }
  let(:game) { build(:game) }
  let(:bundle_tier_game) { build(:bundle_tier_game, bundle_tier:) }

  context "with an anonymous user" do
    let(:user) { nil }

    let(:donator_bundle) { DonatorBundle.create_from(bundle, donator: create(:donator)) }
    let(:donation) { create(:donation) }
    let(:donator) { create(:donator) }
    let(:key) { create(:key) }

    let(:admin_user) { create(:admin_user) }

    include_examples "allows reading public information"
    include_examples "disallows modifying public information"
    include_examples "disallows accessing private information"
    include_examples "disallows accessing admin users"
  end

  context "with a known donator" do
    let(:user) { create(:donator) }

    let(:own_bundle) { DonatorBundle.create_from(bundle, donator: user) }
    let(:other_bundle) { create(:donator_bundle, donator: other_donator) }

    let(:own_donation) { create(:donation, donator: user) }
    let(:other_donation) { create(:donation, donator: other_donator) }

    let(:own_donator) { user }
    let(:other_donator) { create(:donator) }

    let(:own_key) { create(:key, donator_bundle_tier: own_bundle.donator_bundle_tiers.first) }
    let(:other_key) { create(:key, donator_bundle_tier: other_bundle.donator_bundle_tiers.first) }
    let(:unassigned_key) { create(:key, donator_bundle_tier: nil) }

    let(:admin_user) { create(:admin_user) }

    include_examples "allows reading public information"
    include_examples "disallows modifying public information"
    include_examples "disallows accessing admin users"

    it "allows reading own bundles" do
      expect(ability).to be_able_to(:read, own_bundle)
      expect(ability).not_to be_able_to(%I[manage update delete], own_bundle)
      expect(ability).not_to be_able_to(%I[read manage update delete], other_bundle)
    end

    it "allows reading own donations" do
      expect(ability).to be_able_to(:read, own_donation)
      expect(ability).not_to be_able_to(%I[manage update delete], own_donation)
      expect(ability).not_to be_able_to(%I[read manage update delete], other_donation)
    end

    it "allows reading own donators" do
      expect(ability).to be_able_to(:read, own_donator)
      expect(ability).not_to be_able_to(%I[manage update delete], own_donator)
      expect(ability).not_to be_able_to(%I[read manage update delete], other_donator)
    end

    it "allows reading own keys" do
      expect(ability).to be_able_to(:read, own_key)
      expect(ability).not_to be_able_to(%I[manage update delete], own_key)
      expect(ability).not_to be_able_to(%I[read manage update delete], other_key)
      expect(ability).not_to be_able_to(%I[read manage update delete], unassigned_key)
    end
  end
end
