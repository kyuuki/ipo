Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "ipo_companies#index"

  devise_for :users

  resources :ipo_companies
  resources :accounts
  resources :applications
end
