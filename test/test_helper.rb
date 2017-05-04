# encoding: utf-8

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/reporters'
Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter)

require "minitest/rails/capybara"
require "capybara/rails"
require "capybara/poltergeist"
Capybara.javascript_driver = :poltergeist

class ActiveSupport::TestCase

#  setup :load_seeds

  #set_fixture_class sip_tclase: "Sip::Tclase"
  #set_fixture_class "sip/tsitio": Sip::Tsitio

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  
  #Rails.application.load_seed

  # Add more helper methods to be used by all tests here...
  protected
  def load_seeds
    load "#{Rails.root}/db/seeds.rb"
  end
end

class ActionDispatch::IntegrationTest
  # http://www.rubytutorial.io/how-to-test-an-autocomplete-with-rails/
  include Capybara::DSL

  require 'capybara/poltergeist'

  Capybara.javascript_driver = :poltergeist

  def teardown
    Capybara.current_driver = nil
  end
end

# See: https://gist.github.com/mperham/3049152
class ActiveRecord::Base
   mattr_accessor :shared_connection
   @@shared_connection = nil

   def self.connection
     @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
   end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
