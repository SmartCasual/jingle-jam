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

  post "/stripe/prep-checkout", to: "stripe_payments#prep_checkout_session"
  post "/stripe/webhook", to: "stripe_payments#webhook"

  get "/api/donations", to: "api#donations", as: "donations_api"
  get "/api/fundraisers", to: "api#fundraisers", as: "fundraisers_api"
  get "/api/curated-streamers", to: "api#curated_streamers", as: "curated_streamers_api"
  get "/api/totals", to: "api#totals", as: "totals_api"

  post "/paypal/prep-checkout", to: "paypal_payments#prep_checkout_session"
  post "/paypal/complete-checkout/:order_id", to: "paypal_payments#complete_checkout"
  post "/paypal/webhook", to: "paypal_payments#webhook"

  namespace :account do
    devise_scope :donator do
      post :confirm_email_address, to: "confirmations#show"
    end
  end

  devise_for(:donators,
    only: :omniauth_callbacks,
    controllers: {
      omniauth_callbacks: "account/omniauth_callbacks",
    },
  )

  scope "(:locale)", defaults: { locale: "en" }, locale: /#{I18n.available_locales.join("|")}/ do
    devise_for(:donators,
      skip: :omniauth_callbacks,
      path_names: {
        sign_in: "login",
        sign_out: "logout",
        sign_up: "sign-up",
      },
      controllers: {
        confirmations: "account/confirmations",
      },
    )

    resources :fundraisers, only: [:index, :show] do
      resources :donations, only: %i[index new create], controller: "fundraisers/donations"
      resources :curated_streamers, path: "streams", only: [:show] do
        member do
          get :admin
        end
      end
    end

    resources :curated_streamers, path: "streams", only: [:show] do
      member do
        get :choose_fundraiser, path: "choose-fundraiser"
      end
    end

    resource :account, only: %i[show], controller: "account" do
      resources :donations, only: [:index], controller: "account/donations"
      resources :bundles, only: [:index, :show], controller: "account/bundles"

      get "/request-login-email", to: "account#request_login_email"
      post "/send-login-email", to: "account#send_login_email"

      get "/log-in-via-token/:id/:token", to: "account#log_in_via_token", as: "log_in_via_token"

      get "/login-options", to: "account#login_options"
      patch "/update-login-options", to: "account#update_login_options"

      delete "/disconnect-twitch", to: "account#disconnect_twitch"
    end

    resources :charities, only: [:index, :show]
    resources :games, only: [:show]

    root to: "home#home"
  end
end
