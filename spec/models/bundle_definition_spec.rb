require "rails_helper"

RSpec.describe BundleDefinition, type: :model do
  subject(:bundef) { described_class.new }

  describe "state machine" do
    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:live).on_event(:publish) }
    it { is_expected.to transition_from(:live).to(:draft).on_event(:retract) }
  end
end
