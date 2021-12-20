require 'test_helper'
require 'nokogiri'

module Heb412Gen
  class ControlAccesoSisarchControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
    end

    # No autenticado
    ################

    test "sin autenticar no debe acceder a sisarch " do
      assert_raise CanCan::AccessDenied do
        get ENV['RUTA_RELATIVA'] + "/sis/arch"
      end
    end

    test "sin autenticar no debe acceder a sisini " do
      assert_raise CanCan::AccessDenied do
        get heb412_gen.sisini_path
      end
    end

    test "no autenticado no crea  carpeta nueva" do
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/nueva"
      end
    end

    test "no autenticado no accede a hcm importadatos" do
      assert_raise CanCan::AccessDenied do
        get ENV['RUTA_RELATIVA'] + "/plantillashcm/importadatos"
      end
    end

    test "no autenticado no post hcm importadatos" do
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/plantillashcm/importadatos"
      end
    end

    test "no autenticado no elimina carpeta" do
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/eliminardir"
      end
    end

    test "no autenticado no crea archivo nuevo" do
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/nuevo"
      end
    end

    test "no autenticado no elimina archivo" do
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/eliminararc"
      end
    end

    test "sin autenticar no actleeme" do
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/actleeme"
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "operador sin grupo  no debe acceder a sisarch " do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get ENV['RUTA_RELATIVA'] + "/sis/arch"
      assert_response :ok
    end

    test "operador sin grupo  no debe acceder a sisini " do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get heb412_gen.sisini_path
      assert_response :ok
    end

    test "autenticado como operador sin grupo  no crea  carpeta nueva" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/nueva"
      end
    end

    test "autenticado como operador sin grupo no elimina carpeta" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/eliminardir"
      end
    end

    test "autenticado como operador sin grupo  no crea archivo nuevo" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/nuevo"
      end
    end

    test "autenticado como operador sin grupo no elimina archivo" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/eliminararc"
      end
    end

    test "autenticado como operador sin grupo no actleeme" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/actleeme"
      end
    end

    test "operador sin grupo no accede a hcm importadatos" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get ENV['RUTA_RELATIVA'] + "/plantillashcm/importadatos"
      end
    end

    test "operador sin grupo no post hcm importadatos" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/plantillashcm/importadatos"
      end
    end
    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.sip_grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe presentar sisarch" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get ENV['RUTA_RELATIVA'] + "/sis/arch"
      assert_response :ok
    end

    test "autenticado como operador analista no crea  carpeta nueva" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/nueva"
      end
    end

    test "autenticado como operador analista no elimina carpeta" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/eliminardir"
      end
    end

    test "autenticado como operador analista no crea archivo nuevo" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/nuevo"
      end
    end

    test "autenticado como operador analista no elimina archivo" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/eliminararc"
      end
    end

    test "autenticado como operador analista no actleeme" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/sis/actleeme"
      end
    end

    test "autenticado como operador analista debe presentar sisini" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get heb412_gen.sisini_path
      assert_response :ok
    end

    test "operador analista no accede a hcm importadatos" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get ENV['RUTA_RELATIVA'] + "/plantillashcm/importadatos"
      end
    end

    test "operador analista no post hcm importadatos" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post ENV['RUTA_RELATIVA'] + "/plantillashcm/importadatos"
      end
    end

  end
end
