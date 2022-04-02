require "rails_helper"
require "cancan/matchers"

require_relative "shared_examples/admin_comments"
require_relative "shared_examples/admin_users"
require_relative "shared_examples/private_info"
require_relative "shared_examples/public_info"

RSpec.describe AdminAbility do
  subject(:ability) { described_class.new(user) }

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
  end

  context "with a known admin" do
    let(:user) { create(:admin_user) }

    include_examples "allows reading public information"
    include_examples "disallows modifying public information"
    include_examples "disallows accessing private information"
    include_examples "disallows accessing admin users"

    ApplicationAbility.public_classes.each do |public_class|
      include_examples "allows adding comments on public information", public_class: public_class
      include_examples "allows managing own comments on public information", public_class:
    end

    it "allows reading self" do
      expect(ability).to be_able_to(:read, user)
    end

    context "with data entry permissions" do
      before do
        user.update(data_entry: true)
      end

      include_examples "allows managing public information"
    end

    context "with support permissions" do
      before do
        user.update(support: true)
      end

      include_examples "allows reading donation information"
    end

    context "with user management permissions" do
      before do
        user.update(manages_users: true)
      end

      include_examples "allows managing admin users"
    end

    context "with an all-access user" do
      before do
        user.update(full_access: true)
      end

      include_examples "allows managing public information"
      include_examples "allows reading donation information"
      include_examples "allows managing admin users"
    end
  end
end
