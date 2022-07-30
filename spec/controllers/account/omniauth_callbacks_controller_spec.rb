RSpec.describe Account::OmniauthCallbacksController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:request) { @request } # rubocop:disable RSpec/InstanceVariable
  let(:donator) { create(:donator, email_address: donator_email_address) }
  let(:email_address) { nil }
  let(:donator_email_address) { "test@example.com" }

  before do
    request.env["devise.mapping"] = Devise.mappings[:donator]
    request.env["omniauth.auth"] = {
      "provider" => provider,
      "uid" => uid,
      "info" => {
        "email" => email_address,
      },
    }
  end

  describe "#token" do
    let(:provider) { "token" }

    context "if the donator is found" do
      let(:uid) { donator.id }

      it "returns a redirect" do
        get :token
        expect(response).to have_http_status(:redirect)
      end

      it "logs the donator in" do
        get :token
        expect(session["warden.user.donator.key"]&.first&.first).to eq(donator.id)
      end

      it "redirects to the after sign in path" do
        get :token
        expect(response).to redirect_to(controller.after_sign_in_path_for(donator))
      end

      context "if the donator's current email address matches the one provided" do
        let(:email_address) { donator_email_address }

        it "confirms the donator's email address" do
          expect { get :token }.to(change { donator.reload.confirmed_at })
        end
      end

      context "if the donator's current email address does not match the one provided" do
        let(:email_address) { "not-the-same-email-address@example.com" }

        it "does not confirm the donator's email address" do
          expect { get :token }.not_to(change { donator.reload.confirmed_at })
        end
      end

      context "if the donator's current email address matches the one provided but they're both blank" do
        let(:donator_email_address) { "" }
        let(:email_address) { "" }

        it "does not confirm the donator's email address" do
          expect { get :token }.not_to(change { donator.reload.confirmed_at })
        end
      end
    end

    context "if the donator is not found" do
      let(:uid) { "not-a-real-donator-id" }

      it "returns a 404" do
        get :token
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#twitch" do
    let(:provider) { "twitch" }
    let(:uid) { SecureRandom.uuid }

    context "if the twitch UID matches an existing donator" do
      before { donator.update(twitch_id: uid) }

      it "returns a redirect" do
        get :twitch
        expect(response).to have_http_status(:redirect)
      end

      it "logs the donator in" do
        get :twitch
        expect(session["warden.user.donator.key"]&.first&.first).to eq(donator.id)
      end

      it "redirects to the after sign in path" do
        get :twitch
        expect(response).to redirect_to(controller.after_sign_in_path_for(donator))
      end

      it "does not update the donator's twitch ID" do
        expect { get :twitch }.not_to(change { donator.reload.twitch_id })
      end

      context "if the donator's current email address matches the one provided" do
        let(:email_address) { donator_email_address }

        it "confirms the donator's email address" do
          expect { get :twitch }.to(change { donator.reload.confirmed_at })
        end
      end

      context "if the donator's current email address does not match the one provided" do
        let(:email_address) { "not-the-same-email-address@example.com" }

        it "does not confirm the donator's email address" do
          expect { get :twitch }.not_to(change { donator.reload.confirmed_at })
        end
      end

      context "if the donator's current email address matches the one provided but they're both blank" do
        let(:donator_email_address) { "" }
        let(:email_address) { "" }

        it "does not confirm the donator's email address" do
          expect { get :twitch }.not_to(change { donator.reload.confirmed_at })
        end
      end
    end

    context "if the twitch email address matches an existing donator but the UID doesn't" do
      let(:email_address) { donator.email_address }

      before { donator.update(twitch_id: nil) }

      it "returns a redirect" do
        get :twitch
        expect(response).to have_http_status(:redirect)
      end

      it "logs the donator in" do
        get :twitch
        expect(session["warden.user.donator.key"]&.first&.first).to eq(donator.id)
      end

      it "redirects to the after sign in path" do
        get :twitch
        expect(response).to redirect_to(controller.after_sign_in_path_for(donator))
      end

      it "updates the donator's twitch ID" do
        expect { get :twitch }.to(change { donator.reload.twitch_id }.to(uid))
      end

      it "confirms the donator's email address" do
        expect { get :twitch }.to(change { donator.reload.confirmed_at })
      end
    end

    context "if neither the twitch UID nor email address match an existing donator" do
      let(:email_address) { "test@example.com" }
      let(:uid) { SecureRandom.uuid }

      before do
        donator.update(
          twitch_id: nil,
          email_address: nil,
        )
      end

      it "creates a new donator" do
        expect { get :twitch }.to change(Donator, :count).by(1)
      end

      it "returns a redirect" do
        get :twitch
        expect(response).to have_http_status(:redirect)
      end

      it "logs the donator in" do
        get :twitch
        expect(session["warden.user.donator.key"]&.first&.first).to eq(Donator.last.id)
      end

      it "redirects to the after sign in path" do
        get :twitch
        expect(response).to redirect_to(controller.after_sign_in_path_for(Donator.last))
      end

      it "updates the donator's twitch ID" do
        get :twitch
        expect(Donator.last.twitch_id).to eq(uid)
      end

      it "sets and confirms the donator's email address" do
        get :twitch
        expect(Donator.last.email_address).to eq(email_address)
        expect(Donator.last.confirmed_at).to be_present
      end
    end
  end
end
