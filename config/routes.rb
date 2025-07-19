Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      # === 🔐 Authentication ===
      post   '/auth/shop_signup',        to: 'auth#shop_signup',       as: :shop_signup
      post   '/auth/shop_login',         to: 'auth#shop_login',        as: :shop_login
      post   '/auth/technician_signup',  to: 'auth#technician_signup', as: :technician_signup
      post   '/auth/technician_login',   to: 'auth#technician_login',  as: :technician_login
      post   '/auth/customer_signup',    to: 'auth#customer_signup',   as: :customer_signup
      post   '/auth/customer_login',     to: 'auth#customer_login',    as: :customer_login
      post   '/auth/refresh',            to: 'auth#refresh',           as: :refresh_token
      delete '/auth/logout',             to: 'auth#logout',            as: :logout

      get    '/profile',                 to: 'users#profile',          as: :user_profile
      resources :users, only: [:update, :destroy]

      resources :shops do
        resources :users, only: [:index], as: :shop_users
      end

      resources :service_requests, only: [:create, :destroy] do
        collection do
          get :my_requests,       as: :my_service_requests       # Customer
          get :shop_requests,     as: :shop_service_requests     # Shop Admin
        end

        member do
          put :assign_technician, as: :assign_service_technician # Shop Admin
          put :resolve,           as: :resolve_service_request    # Technician
        end
      end

      # === ⏱️ Time Tickets ===
      resources :time_tickets, only: [] do
        collection do
          get :shop_tickets, as: :shop_time_tickets              # Shop Admin
        end
        member do
          put :approve, as: :approve_time_ticket                 # Shop Admin
        end
      end
      post '/time_tickets', to: 'time_tickets#create', as: :create_time_ticket # Technician

      post 'invoices/generate', to: 'invoices#generate'
      get 'invoices/:id/download', to: 'invoices#download'

    end
  end
end
