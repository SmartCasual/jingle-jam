require "rails_helper"

RSpec.describe NotificationsMailer, type: :mailer do
  let(:from_address) { "jingle-jam@example.com" }
  let(:donator_email_address) { "donator@example.com" }
  let(:donator) { FactoryBot.create(:donator, email_address: donator_email_address) }

  around do |example|
    with_env("FROM_EMAIL_ADDRESS" => from_address) do
      example.run
    end
  end

  describe "donation_received" do
    let(:mail) { NotificationsMailer.donation_received(donator) }

    it "renders the headers" do
      expect(mail.subject).to eq("Donation received")
      expect(mail.to).to eq([donator_email_address])
      expect(mail.from).to eq([from_address])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Thanks")
    end
  end

  describe "bundle_assigned" do
    let(:mail) { NotificationsMailer.bundle_assigned(donator) }

    it "renders the headers" do
      expect(mail.subject).to eq("Bundle assigned")
      expect(mail.to).to eq([donator_email_address])
      expect(mail.from).to eq([from_address])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Thanks")
    end
  end
end
