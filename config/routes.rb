Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post   '/auth/shop_signup',      to: 'auth#shop_signup'
      post   '/auth/shop_login',       to: 'auth#shop_login'

      post   '/auth/technician_signup', to: 'auth#technician_signup'
      post   '/auth/technician_login',  to: 'auth#technician_login'

      post   '/auth/customer_signup',   to: 'auth#customer_signup'
      post   '/auth/customer_login',    to: 'auth#customer_login'

      post   '/auth/refresh',           to: 'auth#refresh'
      delete '/auth/logout',            to: 'auth#logout'

      resources :shops
      get 'profile', to: 'users#profile'

      resources :shops, only: [] do
        resources :users, only: [:index]
      end

      resources :users, only: [:update, :destroy]            
    end
  end
end
