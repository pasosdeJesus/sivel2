# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoGruposperControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @grupoper = Msip::Grupoper.create!(PRUEBA_GRUPOPER)
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @vicol = Sivel2Gen::Victimacolectiva.create!(
        grupoper_id: @grupoper.id,
        caso_id: @caso.id,
      )
      @vicol.save!
      @orgsocial = Msip::Orgsocial.create!(PRUEBA_ORGSOCIAL)
    end

    # No autenticado
    ################

    test "sin autenticar no debe acceder a grupos de personas" do
      assert_raise CanCan::AccessDenied do
        get msip.gruposper_path + '?term="Cauca"'
      end
    end

    test "sin autenticar no debe acceder a grupos de personas reemplazar" do
      assert_raise CanCan::AccessDenied do
        get msip.gruposper_remplazar_path + "?grupoper_id=#{@grupoper.id}&victimacolectiva_id=#{@vicol.id}"
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.gruposper_path + '.json?term="Cauca"'

      assert_response :ok
    end

    test "autenticado como operador sin grupo debe presentar gruposper remplazar" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get msip.gruposper_remplazar_path + "?grupoper_id=#{@grupoper.id}&victimacolectiva_id=#{@vicol.id}"
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista debe presentar listado grupoper" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get msip.gruposper_path + '.json?term="Cauca"'

      assert_response :ok
    end

    test "autenticado como operador analista debe presentar listado grupoper remplazar" do
      skip # Response body: Ya existe ese grupo de personas en el caso.
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get msip.gruposper_remplazar_path + "?grupoper_id=#{@grupoper.id}&victimacolectiva_id=#{@vicol.id}&caso_id=#{@caso.id}"

      assert_response :ok
    end

    # Autenticado como obeservador de casos
    #######################################################

    test "autenticado como observador debe presentar listado grupoper" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OBS)
      sign_in current_usuario
      get msip.gruposper_path + '.json?term="Cauca"'

      assert_response :ok
    end
  end
end
