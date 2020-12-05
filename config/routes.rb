Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  get '/oauth', to: 'oauth#index'
  get '/callback', to: 'callback#index'
end
