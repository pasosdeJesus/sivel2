require "test_helper"
require 'capybara/poltergeist'

class NilLogger
    def puts * ; end
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  driven_by :poltergeist, screen_size: [1400, 1400], options: { 
    js_errors: true,
    logger: NilLogger.new#,
#    phantomjs_logger: STDOUT,
#    phantomjs_options: ['--debug=true'],
#    debug: true 
  }

  def setup
#    load "#{Rails.root}/db/seeds.rb"
  end

  def teardown
  end

end
