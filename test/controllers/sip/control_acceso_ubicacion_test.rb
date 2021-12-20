require 'test_helper'

module Sip
  class ControlAccesoOrgsocialesControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @caso = Sivel2Gen::Caso.create!(memo: "prueba", fecha: "2021-12-07")
    end

    # No autenticado
    ################

    test "sin autenticar no debe permitir acceder ubicaciones/nuevo" do
      assert_raise CanCan::AccessDenied do
        get sip.ubicaciones_nuevo_path
      end
    end


    test "sin autenticar no debe crear ubicaciones nuevo" do
      assert_raise CanCan::AccessDenied do
        get sip.ubicaciones_nuevo_path + "?caso_id=#{@caso.id}"
      end
    end


    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar ubicaciones/nuevo" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sip.ubicaciones_nuevo_path
      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.sip_grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe presentar ubi/nuevo" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.ubicaciones_nuevo_path
      assert_response :ok
    end


  end
end
