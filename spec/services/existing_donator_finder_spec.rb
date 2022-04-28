RSpec.describe ExistingDonatorFinder do
  describe ".find(current_donator:, email_address:)" do
    let!(:unconfirmed_amy) do
      create(:donator, email_address: "amy@example.com")
    end

    let!(:confirmed_amy) do
      create(:donator, :confirmed, email_address: "amy@example.com")
    end

    let!(:unconfirmed_brian) do
      create(:donator, email_address: "brian@example.com")
    end

    let!(:confirmed_catherine) do
      create(:donator, :confirmed, email_address: "catherine@example.com")
    end

    let(:new_donator) { build(:donator) }

    def find(d: nil, e: nil) # rubocop:disable Naming/MethodParameterName
      described_class.find(
        current_donator: d || current_donator,
        email_address: e || email_address,
      )
    end

    context "when no email address is given" do
      let(:email_address) { nil }

      it "always returns the current_donator" do
        expect(find(d: confirmed_amy)).to eq(confirmed_amy)
        expect(find(d: unconfirmed_amy)).to eq(unconfirmed_amy)
        expect(find(d: unconfirmed_brian)).to eq(unconfirmed_brian)
        expect(find(d: confirmed_catherine)).to eq(confirmed_catherine)
        expect(find(d: new_donator)).to eq(new_donator)
      end
    end

    context "when an unknown email address is given" do
      let(:email_address) { "unrelated@example.com" }

      it "always returns the current_donator" do
        expect(find(d: confirmed_amy)).to eq(confirmed_amy)
        expect(find(d: unconfirmed_amy)).to eq(unconfirmed_amy)
        expect(find(d: unconfirmed_brian)).to eq(unconfirmed_brian)
        expect(find(d: confirmed_catherine)).to eq(confirmed_catherine)
        expect(find(d: new_donator)).to eq(new_donator)
      end
    end

    context "when the email address of a confirmed donator is given" do
      let(:email_address) { confirmed_catherine.email_address }

      context "and the current donator is not given" do
        let(:current_donator) { nil }

        it "returns the confirmed donator" do
          expect(find).to eq(confirmed_catherine)
        end
      end

      context "and the current donator is a new record" do
        let(:current_donator) { new_donator }

        it "prefers the confirmed donator" do
          expect(find).to eq(confirmed_catherine)
        end
      end

      context "and the current donator is an existing record" do
        let(:current_donator) { confirmed_amy }

        it "prefers the current donator" do
          expect(find).to eq(confirmed_amy)
        end
      end
    end

    context "when the email address of an unconfirmed donator is given" do
      let(:email_address) { unconfirmed_brian.email_address }

      context "and the current donator is not given" do
        let(:current_donator) { nil }

        it "returns the unconfirmed donator" do
          expect(find).to eq(unconfirmed_brian)
        end
      end

      context "and the current donator is a new record" do
        let(:current_donator) { new_donator }

        it "prefers the current donator" do
          expect(find).to eq(new_donator)
        end
      end

      context "and the current donator is an existing record" do
        let(:current_donator) { confirmed_amy }

        it "prefers the current donator" do
          expect(find).to eq(confirmed_amy)
        end
      end
    end

    context "when the email address of a confirmed and unconfirmed donator is given" do
      let(:email_address) { confirmed_amy.email_address }

      context "and the current donator is not given" do
        let(:current_donator) { nil }

        it "returns the confirmed donator" do
          expect(find).to eq(confirmed_amy)
        end
      end

      context "and the current donator is a new record" do
        let(:current_donator) { new_donator }

        it "prefers the confirmed donator" do
          expect(find).to eq(confirmed_amy)
        end
      end

      context "and the current donator is an existing record" do
        let(:current_donator) { unconfirmed_brian }

        it "prefers the current donator" do
          expect(find).to eq(unconfirmed_brian)
        end
      end

      context "and the current donator is the confirmed version" do
        let(:current_donator) { confirmed_amy }

        it "prefers the current donator" do
          expect(find).to eq(confirmed_amy)
        end
      end

      context "and the current donator is the unconfirmed version" do
        let(:current_donator) { unconfirmed_amy }

        it "prefers the current donator" do
          expect(find).to eq(unconfirmed_amy)
        end
      end
    end

    context "when no email address or current donator is given" do
      let(:email_address) { nil }
      let(:current_donator) { nil }

      it "raises an exception" do
        expect { find }.to raise_error(
          ArgumentError,
          "You must provide either an email address or a current donator",
        )
      end
    end
  end
end
