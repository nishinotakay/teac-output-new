# frozen_string_literal: true

# Core Dependencies
require 'spec_helper'
require_relative '../config/environment'
require 'rspec/rails'

# Environment Setup
ENV['RAILS_ENV'] ||= 'test'
abort('The Rails environment is running in production mode!') if Rails.env.production?

# Additional Libraries
require 'selenium-webdriver'
require 'capybara/rspec'
require 'support/factory_bot'

# Register Selenium Chrome Headless Driver
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << '--headless'
  options.args << '--disable-gpu'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Require Support Files
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# ActiveRecord Configuration
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.before(:suite) do
    ActiveRecord::Base.logger = nil

    if defined?(Bullet) && Rails.env.test?
      Bullet.enable = true
      Bullet.raise = true
      Bullet.unused_eager_loading_enable = false
    end

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  config.before(:each) do
    Rails.cache.clear
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each) do |example|
    Bullet.profile do
      example.run
    end
  end

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome
  end
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  # ↓letを使用したときに、FactoryBotが使用できるように設定
  config.include FactoryBot::Syntax::Methods
    config.before(:each) do |example|
      if example.metadata[:type] == :system
        if example.metadata[:js]
          driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
        else
          driven_by :rack_test
        end
      end
    end
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include SystemSpecSupport, type: :system
  config.include WaitForAjax, type: :system
  # fixture_file_uploadメソッドを使用できる様に設定
  config.include ActionDispatch::TestProcess::FixtureFile
end
