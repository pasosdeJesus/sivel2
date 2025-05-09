# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoOrgsocialesControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      Rails.application.try(:reload_routes_unless_loaded)
      @caso = Sivel2Gen::Caso.create!(memo: "prueba", fecha: "2021-12-07")
    end

    # No autenticado
    ################

    test "sin autenticar no debe permitir acceder ubicaciones/nuevo" do
      assert_raise CanCan::AccessDenied do
        get msip.nueva_ubicacion_path
      end
    end

    test "sin autenticar no debe crear ubicaciones nuevo" do
      assert_raise CanCan::AccessDenied do
        get msip.nueva_ubicacion_path + "?caso_id=#{@caso.id}"
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar ubicaciones/nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.nueva_ubicacion_path

      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista debe presentar ubi/nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get msip.nueva_ubicacion_path

      assert_response :ok
    end
  end
end
