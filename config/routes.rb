Rails.application.routes.draw do
  post '/mail', to: 'events#mail', as: :mail;
  
  post 'events/indexpast'
  
  get  'events/indexpast'
  
  post 'events/attendance'
  
  get 'events/new'

  get 'events/index'

  get 'events/edit'
  
  post '/events/:id', to: 'events#show'
  resources :events
  
  root :to => 'infos#index'

  devise_for :users, :controllers => {
   :registrations => 'users/registrations',
   :sessions => 'users/sessions',
   :passwords => 'users/passwords'
  }
  
  devise_scope :user do
    get 'my_page' => 'users/registrations#my_page'
  end
end
