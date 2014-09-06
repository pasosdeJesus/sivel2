ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'rubygems'
require 'spork'
require 'rspec/rails'
require 'factory_girl'
require 'capybara/rspec'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

end

Spork.each_run do
  # This code will be run each time you run your specs.

end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

	# De https://gist.github.com/Bregor/1053489
	config.use_transactional_examples= true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

	config.include FactoryGirl::Syntax::Methods

	config.include Capybara::DSL

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end

	config.include Rails.application.routes.url_helpers

	config.include Devise::TestHelpers, :type => :controller
	#config.include ControllerHelpers, :type => :controller

  Capybara.javascript_driver = :webkit
end


