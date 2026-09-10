Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins_list = if Rails.env.development?
                     [/\Ahttp:\/\/localhost(:\d+)?\z/]
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
