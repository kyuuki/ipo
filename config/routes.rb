Rails.application.routes.draw do
  resources :accounts
  root to: "ipo_companies#index"

  devise_for :users
  resources :ipo_companies
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
