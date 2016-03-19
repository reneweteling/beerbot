Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  authenticate :user do  
    root 'beers#home'
    resources :beers, only: [:index, :create]
  end

  namespace :api, :defaults => { :format => 'json' } do
    namespace :v1 do
      devise_for :users
      resources :beers
      resources :users
    end
  end

end
