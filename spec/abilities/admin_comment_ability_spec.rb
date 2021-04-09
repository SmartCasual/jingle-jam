require "rails_helper"
require "cancan/matchers"

require_relative "shared_examples/admin_comments"
require_relative "shared_examples/admin_users"
require_relative "shared_examples/private_info"
require_relative "shared_examples/public_info"

RSpec.describe AdminCommentAbility do
  subject(:ability) { described_class.new(user) }

  let(:comment) { FactoryBot.build(:admin_comment) }

  let(:bundle_definition) { FactoryBot.build(:bundle_definition) }
  let(:charity) { FactoryBot.build(:charity) }
  let(:game) { FactoryBot.build(:game) }
  let(:game_entry) { FactoryBot.build(:bundle_definition_game_entry) }

  let(:bundle) { FactoryBot.create(:bundle) }
  let(:donation) { FactoryBot.create(:donation) }
  let(:donator) { FactoryBot.create(:donator) }
  let(:key) { FactoryBot.create(:key) }

  let(:admin_user) { FactoryBot.create(:admin_user) }

  context "with an unknown user" do
    let(:user) { nil }

    include_examples "disallows reading public information"
    include_examples "disallows modifying public information"
    include_examples "disallows accessing private information"
    include_examples "disallows accessing admin users"
    include_examples "disallows accessing admin comments"
  end

  context "with a known admin" do
    let(:user) { FactoryBot.create(:admin_user) }

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
