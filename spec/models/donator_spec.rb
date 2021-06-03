require "rails_helper"

RSpec.describe Donator do
  subject(:donator) { FactoryBot.create(:donator) }

  describe "#total_donations" do
    before do
      FactoryBot.create(:donation,
        donator: donator,
        amount: Money.new(1000, "USD"),
      )
      FactoryBot.create(:donation,
        donator: donator,
        amount: Money.new(1000, "GBP"),
      )
      FactoryBot.create(:donation,
        donator: donator,
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
end
