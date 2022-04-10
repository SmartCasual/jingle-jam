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

  describe "#hmac" do
    let(:sha256_digest) { OpenSSL::Digest.new("SHA256") }
    let(:hmac_secret) { SecureRandom.uuid }

    around do |example|
      with_env("HMAC_SECRET" => hmac_secret) do
        example.run
      end
    end

    it "encodes the user's ID with SHA256" do
      expect(donator.hmac).to eq(HMAC::Generator.new(context: "sessions").generate(id: donator.id.to_s))
    end
  end

  describe "assign_keys" do
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
end
