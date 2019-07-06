Rails.application.routes.draw do
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
