Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/*path', to: 'resources#show'
  patch '/*path', to: 'resources#patch'
end
