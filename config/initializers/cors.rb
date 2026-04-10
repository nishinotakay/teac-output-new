Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins_list = if Rails.env.development?
                     [
                       'http://localhost:5173',
                       'http://localhost:5174',
                       'http://127.0.0.1:5173',
                       'http://127.0.0.1:5174',
                       'http://localhost:3001',
                     ]
                   else
                     [ENV.fetch('FRONTEND_ORIGIN', '')]
                   end
    origins(*origins_list)

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: false
  end
end
