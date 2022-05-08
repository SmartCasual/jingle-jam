require "rails_helper"
require "cancan/matchers"

require_relative "shared_examples/admin_comments"
require_relative "shared_examples/admin_users"
require_relative "shared_examples/private_info"
require_relative "shared_examples/public_info"

RSpec.describe AdminCommentAbility do
  subject(:ability) { described_class.new(user) }

  let(:comment) { build(:admin_comment) }

  let(:bundle) { build(:bundle) }
  let(:bundle_tier) { build(:bundle_tier) }
  let(:charity) { build(:charity) }
  let(:game) { build(:game) }
  let(:bundle_tier_game) { build(:bundle_tier_game) }

  let(:donator_bundle) { create(:donator_bundle) }
  let(:donation) { create(:donation) }
  let(:donator) { create(:donator) }
  let(:key) { create(:key) }

  let(:admin_user) { create(:admin_user) }

  context "with an unknown user" do
    let(:user) { nil }

    include_examples "disallows reading public information"
    include_examples "disallows modifying public information"
    include_examples "disallows accessing private information"
    include_examples "disallows accessing admin users"
    include_examples "disallows accessing admin comments"
  end

  context "with a known admin" do
    let(:user) { create(:admin_user) }

    include_examples "disallows reading public information"
    include_examples "disallows modifying public information"
    include_examples "disallows accessing private information"
    include_examples "disallows accessing admin users"

    ApplicationAbility.public_classes.each do |public_class|
      include_examples("allows adding comments on public information", public_class:)
      include_examples("allows managing own comments on public information", public_class:)
    end
  end
end
