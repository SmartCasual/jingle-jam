require "rails_helper"

RSpec.describe PanicMailer, type: :mailer do
  let(:from_address) { "panic-mailer@example.com" }

  around do |example|
    with_env("FROM_EMAIL_ADDRESS" => from_address) do
      example.run
    end
  end

  describe "#missing_key" do
    let(:mail) { described_class.missing_key(nil, nil) }
    let!(:admins) { create_list(:admin_user, 2) }

    it "renders the headers" do
      expect(mail.subject).to eq("Missing key")
      expect(mail.to).to eq(admins.map(&:email_address))
      expect(mail.from).to eq([from_address])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end
end
