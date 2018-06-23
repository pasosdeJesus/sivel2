# encoding: utf-8

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/reporters'
require 'minitest/rails/capybara'
require 'minitest/rails'
Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter)

Capybara.javascript_driver = :poltergeist


class ActiveSupport::TestCase

  fixtures :all
  
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
