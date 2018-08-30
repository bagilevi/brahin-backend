Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/plugin', to: 'plugin#show'

  get '/(*path)', to: 'resources#show'
  post '/(*path)', to: 'resources#create'
  patch '/(*path)', to: 'resources#patch'
end
