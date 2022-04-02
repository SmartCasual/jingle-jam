require "rails_helper"

RSpec.describe Key do
  describe "#code" do
    subject(:game_key) { create(:key, code: plaintext) }

    let(:plaintext) { SecureRandom.uuid }

    context "when the encryption key is present" do
      let(:output) { game_key.code }

      it "returns the plaintext" do
        expect(output).to eq(plaintext)
      end
    end

    context "when the database is accessed directly" do
      let(:output) do
        ActiveRecord::Base.connection
          .select_one("SELECT code_ciphertext FROM keys WHERE id = '#{game_key.id}' LIMIT 1")
          .fetch("code_ciphertext")
      end

      it "returns the ciphertext" do
        expect(output).not_to eq(plaintext)
        expect(output).not_to be_blank
      end
    end

    context "when looking for the unencrypted column" do
      let(:output) do
        ActiveRecord::Base.connection.select_all("SELECT * FROM keys")
      end

      it "doesn't exist" do
        expect(output.includes_column?("code")).to be(false)
      end
    end
  end
end
