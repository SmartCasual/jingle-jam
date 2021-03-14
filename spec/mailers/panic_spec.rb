require "rails_helper"

RSpec.describe PanicMailer, type: :mailer do
  describe "missing_key" do
    let(:mail) { PanicMailer.missing_key(nil, nil) }
    let!(:admins) { FactoryBot.create_list(:admin_user, 2) }

    it "renders the headers" do
      expect(mail.subject).to eq("Missing key")
      expect(mail.to).to eq(admins.map(&:email))
      expect(mail.from).to eq(["jingle-jam@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end
end
