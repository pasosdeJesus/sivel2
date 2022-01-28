require 'test_helper'

module Sip
  class ControlAccesoUsuariosTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @persona = Sip::Persona.create!(PRUEBA_PERSONA)
      @persona2 = Sip::Persona.create!(PRUEBA_PERSONA)
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @victima = Sivel2Gen::Victima.create!(id_persona: @persona2.id, id_caso: @caso.id)
    end

    # No autenticado
    ################

    test "sin autenticar no debe presentar una persona existente" do
      skip
      assert_raise CanCan::AccessDenied do
        get sip.persona_path(@persona.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo puede" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sivel2/sign_out"
      assert_redirected_to ENV['RUTA_RELATIVA'][0..-2]
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista puede salir" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/sivel2/sign_out"
      assert_redirected_to ENV['RUTA_RELATIVA'][0..-2]
    end


  end
end
