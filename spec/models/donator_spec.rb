require "rails_helper"

RSpec.describe Donator do
  subject(:donator) { create(:donator) }

  describe "#total_donations" do
    before do
      create(:donation,
        donator:,
        amount: Money.new(1000, "USD"),
      )
      create(:donation,
        donator:,
        amount: Money.new(1000, "GBP"),
      )
      create(:donation,
        donator:,
        amount: Money.new(1000, "EUR"),
      )
    end

    it "sums all donations into the primary currency" do
      # TODO: Make this adapt with changing exchange rates
      expect(donator.total_donations).to eq(Money.new(2585, "GBP"))
    end
  end

  describe "token generation" do
    let(:sha256_digest) { OpenSSL::Digest.new("SHA256") }
    let(:hmac_secret) { SecureRandom.uuid }

    around do |example|
      with_env("HMAC_SECRET" => hmac_secret) do
        example.run
      end
    end

    describe "#token" do
      it "encodes the user's ID with SHA256" do
        expect(donator.token).to eq(
          HMAC::Generator.new(context: "sessions").generate(
            id: donator.id.to_s,
          ),
        )
      end

      it "does not change when the email address changes" do
        expect { donator.email_address = "new@example.com" }.not_to change(donator, :token)
      end
    end

    describe "#token_with_email_address" do
      it "encodes the user's ID with SHA256" do
        expect(donator.token_with_email_address).to eq(
          HMAC::Generator.new(context: "sessions").generate(
            id: donator.id.to_s,
            extra_fields: { email_address: donator.email_address },
          ),
        )
      end

      it "changes when the email address changes" do
        expect { donator.email_address = "new@example.com" }.to change(donator, :token_with_email_address)
      end
    end
  end

  describe "#assign_keys" do
    before do
      allow(BundleKeyAssignmentJob).to receive(:perform_later)
    end

    context "with a draft bundle definition" do
      before { create(:bundle_definition, :draft) }

      it "does not assign keys" do
        donator.assign_keys
        expect(BundleKeyAssignmentJob).not_to have_received(:perform_later)
      end
    end

    context "with a live bundle definition" do
      let!(:bundle_definition) { create(:bundle_definition, :live) }

      it "assigns keys to a new bundle" do
        expect { donator.assign_keys }.to change(Bundle, :count).by(1)
        expect(BundleKeyAssignmentJob).to have_received(:perform_later)
          .with(Bundle.last.id)
      end

      context "if the donator already has a bundle for that bundle definition" do
        let!(:bundle) { create(:bundle, bundle_definition:, donator:) }

        it "assigns keys to the existing bundle" do
          expect { donator.reload.assign_keys }.not_to change(Bundle, :count)
          expect(BundleKeyAssignmentJob).to have_received(:perform_later)
            .with(bundle.id)
        end
      end
    end
  end

  describe ".create_from_omniauth!(auth_hash)" do
    subject(:donator) { described_class.create_from_omniauth!(auth_hash) }

    let(:auth_hash) do
      {
        "provider" => "twitch",
        "uid" => provider_uid,
        "info" => {
          "name" => "John Doe",
          "nickname" => "jdoe",
          "email" => "test@example.com",
        },
      }
    end

    let(:provider_uid) { "12345" }

    context "with a valid provider (twitch)" do
      it "creates a new donator" do
        expect { donator }.to change(described_class, :count).by(1)
      end

      it "returns the new donator" do
        expect(donator).to be_a(described_class)
      end

      it "sets the donator's chosen name" do
        expect(donator.chosen_name).to eq(auth_hash["info"]["nickname"])
      end

      it "sets the donator's email address" do
        expect(donator.email_address).to eq(auth_hash["info"]["email"])
      end

      it "sets the donator's twitch uid" do
        expect(donator.twitch_id).to eq(auth_hash["uid"])
      end
    end

    context "with an invalid provider" do
      let(:auth_hash) { { "provider" => "invalid", "uid" => "12345" } }

      it "raises an error" do
        expect { donator }.to raise_error("Unsupported provider: invalid")
      end
    end

    context "with a provider uid that already exists" do
      before do
        create(:donator, twitch_id: provider_uid)
      end

      it "raises an error" do
        expect { donator }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Twitch ID is taken")
      end
    end
  end

  describe "#valid_password?(password)" do
    subject(:result) { donator.valid_password?(password) }

    context "if the donator's password is not blank" do
      let(:donator) { create(:donator, email_address: "test@example.com", password: "password123") }

      context "and the password is correct" do
        let(:password) { "password123" }

        it { is_expected.to be(true) }
      end

      context "and the password is incorrect" do
        let(:password) { "incorrect123" }

        it { is_expected.to be(false) }
      end
    end

    context "if the donator's password is blank" do
      let(:donator) { create(:donator, password: "") }

      context "and the password is correct" do
        let(:password) { "" }

        it { is_expected.to be(false) }
      end

      context "and the password is incorrect" do
        let(:password) { "incorrect123" }

        it { is_expected.to be(false) }
      end
    end
  end

  describe "#email_required?" do
    subject(:result) { donator.email_required? }

    context "if the donator has already set a password" do
      let(:donator) { create(:donator, email_address: "test@example.com", password: "password123") }

      before { donator.reload }

      it { is_expected.to be(true) }
    end

    context "if the donator has not yet set a password" do
      let(:donator) { create(:donator, password: nil) }

      before { donator.reload }

      context "and they have not provided a new password" do
        it { is_expected.to be(false) }
      end

      context "and they have provided a new password" do
        before { donator.password = "password123" }

        it { is_expected.to be(true) }
      end
    end
  end

  describe "#password_required?" do
    it "returns false" do
      expect(donator.password_required?).to be(false)
    end
  end

  describe "#display_name(donator:)" do
    subject(:result) { donator.display_name(current_donator:) }

    let(:donator) { create(:donator, name:, chosen_name:) }
    let(:current_donator) { nil }

    context "if the donator is anonymous" do
      context "with nil names" do
        let(:name) { nil }
        let(:chosen_name) { nil }

        it { is_expected.to eq("Anonymous") }
      end

      context "with blank names" do
        let(:name) { "" }
        let(:chosen_name) { "" }

        it { is_expected.to eq("Anonymous") }
      end
    end

    context "if the donator has a name" do
      let(:name) { "John Doe" }
      let(:chosen_name) { nil }

      it { is_expected.to eq("John Doe") }

      context "if the chosen name is present but blank" do
        let(:chosen_name) { "" }

        it "still returns the name" do
          expect(result).to eq("John Doe")
        end
      end
    end

    context "if the donator has a chosen name" do
      let(:name) { nil }
      let(:chosen_name) { "jdoe" }

      it { is_expected.to eq("jdoe") }
    end

    context "if the donator has a name and a chosen name" do
      let(:name) { "John Doe" }
      let(:chosen_name) { "jdoe" }

      it "returns the donator's chosen name" do
        expect(result).to eq("jdoe")
      end
    end

    context "if the donator is the same as the other donator" do
      let(:current_donator) { donator }
      let(:name) { "John Doe" }
      let(:chosen_name) { "jdoe" }

      it { is_expected.to eq("You") }
    end
  end

  describe "#email_address" do
    let(:donator) { build(:donator, :with_email_address) }

    it "is valid with a valid email address" do
      donator.email_address = "valid@example.com"
      expect(donator).to be_valid
    end

    it "is invalid with an invalid email address" do
      donator.email_address = "invalid"
      expect(donator).not_to be_valid
    end

    it "can be saved if two duplicates are unconfirmed" do
      create(:donator, email_address: donator.email_address)
      expect(donator.save).to be_truthy
    end

    it "cannot be saved if the existing duplicate is confirmed" do
      create(:donator, :confirmed, email_address: donator.email_address)
      expect { donator.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Email address has already been taken")
    end

    it "can be saved if only the new duplicate is confirmed" do
      create(:donator, email_address: donator.email_address)
      donator.confirmed_at = 2.days.ago
      expect(donator.save).to be_truthy
    end

    it "cannot be saved if both duplicates are confirmed" do
      create(:donator, :confirmed, email_address: donator.email_address)
      donator.confirmed_at = 2.days.ago
      expect { donator.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Email address has already been taken")
    end

    it "can be saved if the duplicate is itself" do
      donator.confirm
      expect(donator.reload.save).to be_truthy
    end
  end
end
