require 'test_helper'

module Sip
  class ControlAccesoAHogarTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      #@gupoper = Sip::Grupoper.create!(PRUEBA_GRUPOPER)
      #@orgsocial = Sip::Orgsocial.create!(PRUEBA_ORGSOCIAL)
    end

    # No autenticado
    ################

    test "sin autenticar podría acceder a Acerca de" do
      get Rails.application.config.relative_url_root + "acercade"
      assert_response :ok
    end

    test "sin autenticar podría acceder a controldeacceso" do
      get Rails.application.config.relative_url_root + "controldeacceso"
      assert_response :ok
    end

    test "sin autenticar podría acceder a hogar" do
      get Rails.application.config.relative_url_root + "hogar"
      assert_response :ok
    end

    test "sin autenticar podría acceder a temausuario" do
      get Rails.application.config.relative_url_root + "temausuario"
      assert_response :ok
    end
  end
end
