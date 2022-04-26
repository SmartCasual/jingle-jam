Rails.application.routes.draw do
  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:sessions] = "admin/sessions"

  devise_for :admin_users, devise_config

  ActiveAdmin.routes(self)

  namespace :admin do
    get "/2sv/setup", to: "otp#setup", as: "otp_setup"
    get "/2sv/verify", to: "otp#input", as: "otp_input"
    post "/2sv/verify", to: "otp#verify", as: "otp_verify"
  end

  devise_for :donators, {
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      sign_up: "sign-up",
    },
    controllers: {
      confirmations: "donators/confirmations",
      omniauth_callbacks: "donators/omniauth_callbacks",
    },
  }

  namespace :donators do
    devise_scope :donator do
      post :confirm_email_address, to: "confirmations#show"
    end
  end

  scope "(:locale)", defaults: { locale: "en" }, locale: /#{I18n.available_locales.join("|")}/ do
    resources :donations, except: %i[edit update delete destroy]
    resources :keys, only: [:index]
    resources :charities, only: [:show]
    resources :donators, except: %i[index delete destroy] do
      collection do
        get "/request-a-login-email", to: "donators#request_login_email", as: "request_login_email"
      end

      member do
        get "/log-in-via-token/:token", to: "donators#log_in_via_token", as: "log_in_via_token"
      end
    end
    resources :games, only: [:show]

    get "/streams/:twitch_username", to: "curated_streamers#show", as: "curated_streamer"
    get "/streams/:twitch_username/admin", to: "curated_streamers#admin", as: "curated_streamer_admin"
  end

  post "/stripe/prep-checkout", to: "stripe_payments#prep_checkout_session"
  post "/stripe/webhook", to: "stripe_payments#webhook"

  post "/paypal/prep-checkout", to: "paypal_payments#prep_checkout_session"
  post "/paypal/complete-checkout/:order_id", to: "paypal_payments#complete_checkout"
  post "/paypal/webhook", to: "paypal_payments#webhook"

  get "/:locale" => "home#home"
  root to: "home#home"
end
