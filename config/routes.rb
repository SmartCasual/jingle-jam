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

  scope "(:locale)", defaults: { locale: "en" }, locale: /#{I18n.available_locales.join("|")}/ do
    resources :donations, except: %i[edit update delete destroy]
    resources :keys, only: [:index]
    resources :charities, only: [:show]
    resources :donators, except: %i[index delete destroy]
    resources :games, only: [:show]

    get "/streams/:twitch_username", to: "curated_streamers#show", as: "curated_streamer"
    get "/streams/:twitch_username/admin", to: "curated_streamers#admin", as: "curated_streamer_admin"
  end

  post "/stripe/prep-checkout", to: "stripe_payments#prep_checkout_session"
  post "/stripe/webhook", to: "stripe_payments#webhook"

  post "/paypal/prep-checkout", to: "paypal_payments#prep_checkout_session"
  post "/paypal/complete-checkout/:order_id", to: "paypal_payments#complete_checkout"
  post "/paypal/webhook", to: "paypal_payments#webhook"

  get "/magic-redirect/:donator_id/:hmac", to: "sessions#magic_redirect", as: "magic_redirect"
  post "/logout", to: "sessions#logout"

  get "/:locale" => "home#home"
  root to: "home#home"
end
