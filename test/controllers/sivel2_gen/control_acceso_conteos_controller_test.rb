require 'test_helper'

module Sivel2Gen
  class ControlAccesoConteosControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
    end

    ################
    # No autenticado

    test "sin autenticar no puede acceder a conteos genvic" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_genvic_path
      end
    end

    test "sin autenticar no puede acceder a conteos personas" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_personas_path
      end
    end

    test "sin autenticar no puede acceder a conteos vicitimizaciones" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_victimizaciones_path
      end
    end

    # Autenticado como operador sin grupo

    test "operador sin grupo no puede acceder a conteos genvic" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_genvic_path
      end
    end

    test "operador sin grupo no puede acceder a conteos personas" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_personas_path
      end
    end

    test "operador sin grupo no puede acceder a conteos victimizaciones" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_victimizaciones_path
      end
    end

    # Autenticado como operador analista

    test "operador analista no puede acceder a conteos genvic" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_genvic_path
      end
    end

    test "operador analista no puede acceder a conteos personas" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_personas_path
      end
    end

    test "operador analista no puede acceder a conteos victimizaciones" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.conteos_victimizaciones_path
      end
    end
  end
end
