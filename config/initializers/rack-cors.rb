Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.application.config.x.origen_cors
    resource '*',
      headers: :any,
      methods: [:get, 
                :post, 
                :put, 
                :patch, 
                :delete, 
                :options, 
                :head]
  end
end
