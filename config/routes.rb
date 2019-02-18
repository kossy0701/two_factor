Rails.application.routes.draw do
  root 'pages#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  resource :two_factor_auth, only: [:new, :create, :destroy]

end
