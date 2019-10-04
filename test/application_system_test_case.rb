require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  driven_by :selenium, using: :headless_chrome,
    screen_size: [1400, 1400], options: { 
    #js_errors: true,
    timeout: 3.minutes,
    #logger: NilLogger.new#,
#    phantomjs_logger: STDOUT,
#    phantomjs_options: ['--debug=true'],
#    debug: true 
  }

  def setup
    if Sip::Tclase.all.count == 0
      load "#{Rails.root}/db/seeds.rb"
      Rake::Task['sip:indices'].invoke
    end
  end

  def teardown
  end

end
