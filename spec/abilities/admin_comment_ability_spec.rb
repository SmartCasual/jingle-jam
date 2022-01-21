require "rails_helper"
require "cancan/matchers"

require_relative "shared_examples/admin_comments"
require_relative "shared_examples/admin_users"
require_relative "shared_examples/private_info"
require_relative "shared_examples/public_info"

RSpec.describe AdminCommentAbility do
  subject(:ability) { described_class.new(user) }

  let(:comment) { build(:admin_comment) }

  let(:bundle_definition) { build(:bundle_definition) }
  let(:charity) { build(:charity) }
  let(:game) { build(:game) }
  let(:game_entry) { build(:bundle_definition_game_entry) }

  let(:bundle) { create(:bundle) }
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
      include_examples "allows adding comments on public information", public_class: public_class
      include_examples "allows managing own comments on public information", public_class: public_class
    end
  end
end
