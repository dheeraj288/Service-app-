Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication
      post   '/auth/shop_signup',        to: 'auth#shop_signup'
      post   '/auth/shop_login',         to: 'auth#shop_login'
      post   '/auth/technician_signup',  to: 'auth#technician_signup'
      post   '/auth/technician_login',   to: 'auth#technician_login'
      post   '/auth/customer_signup',    to: 'auth#customer_signup'
      post   '/auth/customer_login',     to: 'auth#customer_login'
      post   '/auth/refresh',            to: 'auth#refresh'
      delete '/auth/logout',             to: 'auth#logout'

      # User profile & management
      get    '/profile',                 to: 'users#profile'
      resources :users, only: [:update, :destroy]

      # Shops and shop-specific users
      resources :shops do
        resources :users, only: [:index]
      end

      # Customer Onboarding
      # (handled under auth#customer_signup with building/elevators nested)

      # Service Requests
      resources :service_requests, only: [:create, :destroy] do
        collection do
          get :my_requests
          get :shop_requests
        end
        member do
          put :assign_technician
          put :resolve
        end
      end

      # Time Tickets
      post   '/time_tickets', to: 'time_tickets#create'
      resources :time_tickets, only: [] do
        collection do
          get :shop_tickets
        end
        member do
          put :approve
          put :reject
          get :invoice_pdf, defaults: { format: 'pdf' }
        end
      end

      # Invoices
      post '/invoices/generate', to: 'invoices#generate'
      get  '/invoices/:id/download', to: 'invoices#download'

      # Quotes
      resources :time_tickets, only: [] do
        resources :quotes, only: [:create]
      end
      resources :quotes, only: [:show, :update] do
        member do
          patch :approve
          patch :reject
        end
      end
      resources :preventive_maintenances, only: [:create, :index, :show] do
        collection do
          get :my
        end
        member do
          patch :assign,     to: 'preventive_maintenances#assign_technician'
          patch :complete,   to: 'preventive_maintenances#complete'
          patch :cancel,     to: 'preventive_maintenances#cancel'
        end
      end
      resources :scheduled_repairs, only: [:create] do
      member do
        post :assign_technician
        post :start
        post :complete
      end
    end
    end
  end
end
