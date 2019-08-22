Rails.application.routes.draw do
  get 'passwordreset/:id' => 'passwordreset#show'
  
  post  'passwordreset/reset'
  
  post '/mail', to: 'events#mail', as: :mail;
  
  post  'events/moneycollection'
  
  post 'events/commentcreate'
  
  get  'events/indexcancel'
  
  post 'events/indexpast'
  
  get  'events/indexpast'
  
  post 'events/attendance'
  
  get 'events/new'

  get 'events/index'

  get 'events/edit'
  
  post '/events/:id', to: 'events#show'
  
  get 'withdraw/taikai'
  
  resources :events
  
  root :to => 'infos#index'

  devise_for :users, :controllers => {
   :registrations => 'users/registrations',
   :sessions => 'users/sessions',
   :passwords => 'users/passwords',
   omniauth_callbacks: 'users/omniauth_callbacks'
   #:omniauth_callbacks => 'users/omniauth_callbacks'
  }
  devise_scope :user do
    get 'my_page' => 'users/registrations#my_page'
  end
end
