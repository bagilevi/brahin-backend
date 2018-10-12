Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount MySinatraApp => '/'

  get '/_spa_dummy', to: 'resources#spa_dummy'
  get '/_local(/*path)', to: 'resources#local'

  get '/_git/pull', to: 'gitsync#pull'
  post '/_git/pull', to: 'gitsync#pull'

  get '/(*path)/_permissions', to: 'resources#permissions'
  put '/(*path)/_permissions', to: 'resources#update_permissions'
  get '/(*path)', to: 'resources#show'
  post '/(*path)', to: 'resources#create'
  patch '/(*path)', to: 'resources#patch'
end
