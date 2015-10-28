Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  root 'beers#home'
  resources :beers, only: [:index, :create]
  
end
