Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  root to: redirect('/app')

  namespace :api, :defaults => { :format => 'json' } do
    namespace :v1 do
      devise_for :users
      resources :beers
      resources :users
    end
  end

end
