Rails.application.routes.draw do
  post 'user_token', to: 'user_token#create'
  post 'user_token_refresh', to: 'token#refresh_token'
  resources :users, defaults: { format: :json }
  root to: 'application#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
