Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Allow all domains (You can be more restrictive by changing `'*'` to a specific domain)
    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :delete, :options]
  end
end
