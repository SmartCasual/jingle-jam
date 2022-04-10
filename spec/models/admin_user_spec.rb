require "rails_helper"

RSpec.describe AdminUser, type: :model do
  describe "#permissions" do
    subject(:permissions) { described_class.new(set_permissions).permissions }

    context "when the admin has no permissions" do
      let(:set_permissions) { {} }

      it { is_expected.to eq([]) }
    end

    context "when the admin has individual permissions" do
      let(:set_permissions) do
        {
          data_entry: true,
          manages_users: true,
          support: true,
          full_access: false,
        }
      end

      it { is_expected.to eq(["data entry", "manages users", "support"]) }
    end

    context "when the admin has full access in addition to any other permissions" do
      let(:set_permissions) do
        {
          data_entry: true,
          manages_users: true,
          support: false,
          full_access: true,
        }
      end

      it { is_expected.to eq(["full access"]) }
    end
  end
end
