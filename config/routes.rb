Rails.application.routes.draw do
  resources :donations, except: [:edit, :update, :delete, :destroy]

  root to: "home#home"
end
