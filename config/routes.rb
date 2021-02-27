Rails.application.routes.draw do
  resources :donations, except: [:edit, :update, :delete, :destroy]

  post "/stripe/prep-checkout", to: "stripe#prep_checkout_session"
  post "/stripe/webhook", to: "stripe#webhook"

  root to: "home#home"
end
