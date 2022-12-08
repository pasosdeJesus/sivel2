require 'test_helper'

module Sivel2Gen
  class ControlAccesoConteosControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
    end

    # No autenticado
    # Consulta pública de casos para usuarios no autenticados
    ################

    # Conteo demográfico de víctimas 
    test "sin autenticar No debería poder contar" do
      byebug
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_personas_path
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    # Conteo demográfico de víctimas 
    test "autenticado como operador sin grupo debe poder contar víctimas" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.conteos_personas_path
      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe poder contar víctimas" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.conteos_personas_path
      assert_response :ok
    end


  end
end
