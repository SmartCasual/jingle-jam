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

  resources :donations, except: %i[edit update delete destroy]
  resources :keys, only: [:index]
  resources :games, only: [:show]
  resources :charities, only: [:show]
  resources :donators, except: %i[index delete destroy]

  get "/streams/:twitch_username", to: "curated_streamers#show", as: "curated_streamer"
  get "/streams/:twitch_username/admin", to: "curated_streamers#admin", as: "curated_streamer_admin"

  post "/stripe/prep-checkout", to: "stripe#prep_checkout_session"
  post "/stripe/webhook", to: "stripe#webhook"

  get "/magic-redirect/:donator_id/:hmac", to: "sessions#magic_redirect", as: "magic_redirect"
  post "/logout", to: "sessions#logout"

  root to: "home#home"
end
