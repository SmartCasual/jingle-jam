Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :donations, except: [:edit, :update, :delete, :destroy]
  resources :keys, only: [:index]

  post "/stripe/prep-checkout", to: "stripe#prep_checkout_session"
  post "/stripe/webhook", to: "stripe#webhook"

  root to: "home#home"
end
