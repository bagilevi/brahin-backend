Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount MySinatraApp => '/'

  get '/_spa_dummy', to: 'resources#spa_dummy'
  get '/_local(/*path)', to: 'resources#local'

  put '/(*path)/_share', to: 'resources#share'
  get '/(*path)/_sharing', to: 'resources#sharing'
  put '/(*path)/_sharing', to: 'resources#update_sharing'
  get '/(*path)', to: 'resources#show'
  post '/(*path)', to: 'resources#create'
  patch '/(*path)', to: 'resources#patch'
end
