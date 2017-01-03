require "test_helper"

class PuedeVerHogarTest < ActionDispatch::IntegrationTest

  include Capybara::DSL
  test "hogar con contenido" do 
    visit Rails.configuration.relative_url_root
    assert page.has_content?("SIVeL")
  end

end
