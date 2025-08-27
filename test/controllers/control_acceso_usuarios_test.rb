# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoUsuariosTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @persona2 = Msip::Persona.create!(PRUEBA_PERSONA)
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @victima = Sivel2Gen::Victima.create!(persona_id: @persona2.id, caso_id: @caso.id)
      @raiz = Rails.application.config.relative_url_root
    end

    # No autenticado
    ################

    test "sin autenticar no debe presentar usuarios nuevo" do
      assert_raise CanCan::AccessDenied do
        get "/usuarios/nuevo"
      end
    end

    test "sin autenticar puede accceder a unlock new" do
      get "/usuarios/unlock/new"

      assert_response :ok
    end

    test "sin autenticar puede accceder a unlock" do
      get "/usuarios/unlock"

      assert_response :ok
    end

    test "sin autenticar puede redirige a iniciar sesion en registrar" do
      get "/usuarios/edit"

      assert_redirected_to "/usuarios/sign_in"
    end

    test "sin autenticar no puede acceder a put edit usuario" do
      put "/usuarios/edit"

      assert_redirected_to "/usuarios/sign_in"
    end

    test "sin autenticar no puede acceder a post usuarios" do
      assert_raise CanCan::AccessDenied do
        post "/usuarios", params: { usuario: { nombre: "ale" } }
      end
    end

    test "sin autenticar no puede acceder a usuarios" do
      get "/usuarios"

      assert_redirected_to @raiz
    end

    test "sin autenticar no debe mostrar usuarios nuevo" do
      usuario_id = Msip::Usuario.take.id
      # assert_raise CanCan::AccessDenied do
        get "/usuarios/" + usuario_id.to_s
      # end
      assert response.body.include?("exception")
    end

    test "sin autenticar no debe editar usuarios" do
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/usuarios/" + usuario_id.to_s + "/edita"
      end
    end

    test "sin autenticar no debe acceder a eliminar usuarios" do
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        delete "/usuarios/" + usuario_id.to_s
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo puede" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sign_out"

      assert_redirected_to @raiz
    end

    test "observador de casos puede accceder a unlock new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/usuarios/unlock/new"

      assert_redirected_to @raiz
    end

    test "observador de casos puede accceder a unlock" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/usuarios/unlock"

      assert_redirected_to @raiz
    end

    test "observador puede acceder a editar su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/usuarios/edit"

      assert_response :ok
    end

    test "observador  puede acceder a put edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      put "/usuarios/edit"

      assert_response :ok
    end

    test "observador  puede acceder a patch edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        patch "/usuarios/" + usuario_id.to_s, params: { usuario: { nombre: "ale" } }
      end
    end

    test "observador no puede acceder a usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/usuarios"

      assert_redirected_to @raiz
    end

    test "observador no puede acceder a post usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post "/usuarios", params: { usuario: { nombre: "ale" } }
      end
    end

    test "observador no debe presentar usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get "/usuarios/nuevo"
      end
    end

    test "observador no debe mostrar usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      # assert_raise CanCan::AccessDenied do
        get "/usuarios/" + usuario_id.to_s
      # end
      assert response.body.include?("exception")
    end

    test "observador no debe editar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/usuarios/" + usuario_id.to_s + "/edita"
      end
    end

    test "observador no debe acceder a eliminar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        delete "/usuarios/" + usuario_id.to_s
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista puede salir" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/sign_out"

      assert_redirected_to @raiz
    end

    test "operador analista puede accceder a unlock new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/usuarios/unlock/new"

      assert_redirected_to @raiz
    end

    test "operador analista puede accceder a unlock" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/usuarios/unlock"

      assert_redirected_to @raiz
    end

    test "analista puede acceder a editar su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/usuarios/edit"

      assert_response :ok
    end

    test "analista puede acceder a put edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      put "/usuarios/edit"

      assert_response :ok
    end

    test "analista no puede acceder a usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/usuarios"

      assert_redirected_to @raiz
    end

    test "analista no puede acceder a post usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post "/usuarios", params: { usuario: { nombre: "ale" } }
      end
    end

    test "analista no debe presentar una usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get "/usuarios/nuevo"
      end
    end

    test "analista no debe mostrar usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      # assert_raise CanCan::AccessDenied do
        get "/usuarios/" + usuario_id.to_s
      # end
      assert response.body.include?("exception")
    end

    test "Analista no debe editar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/usuarios/" + usuario_id.to_s + "/edita"
      end
    end

    test "analista no debe acceder a eliminar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        delete "/usuarios/" + usuario_id.to_s
      end
    end

    test "analista  puede acceder a patch edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      usuario_id = Msip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        patch "/usuarios/" + usuario_id.to_s, params: { usuario: { nombre: "ale" } }
      end
    end
  end
end
