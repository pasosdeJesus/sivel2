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
      @raiz = Rails.application.config.relative_url_root.delete_suffix('/')
    end

    # No autenticado
    ################

    test "sin autenticar no debe presentar usuarios nuevo" do
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/nuevo"
      end
    end

    test "sin autenticar puede accceder a unlock new" do
      get "/sivel2/usuarios/unlock/new"
      assert_response :ok
    end

    test "sin autenticar puede accceder a unlock" do
      get "/sivel2/usuarios/unlock"
      assert_response :ok
    end

    test "sin autenticar puede redirige a iniciar sesion en registrar" do
      get "/sivel2/usuarios/edit"
      assert_redirected_to "/sivel2/sivel2/usuarios/sign_in"
    end

    test "sin autenticar no puede acceder a put edit usuario" do
      put "/sivel2/usuarios/edit"
      assert_redirected_to "/sivel2/sivel2/usuarios/sign_in"
    end

    test "sin autenticar no puede acceder a post usuarios" do
      assert_raise CanCan::AccessDenied do
        post "/sivel2/usuarios", params: {usuario: {nombre: "ale"}}
      end
    end

    test "sin autenticar no puede acceder a usuarios" do
      get "/sivel2/usuarios"
      assert_redirected_to @raiz
    end

    test "sin autenticar no debe mostrar usuarios nuevo" do
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/" + id_usuario.to_s
      end
    end

    test "sin autenticar no debe editar usuarios" do
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/" + id_usuario.to_s + "/edita"
      end
    end

    test "sin autenticar no debe acceder a eliminar usuarios" do
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        delete "/sivel2/usuarios/" + id_usuario.to_s
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo puede" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sivel2/sign_out"
      assert_redirected_to @raiz
    end

    test "observador de casos puede accceder a unlock new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sivel2/usuarios/unlock/new"
      assert_redirected_to @raiz
    end

    test "observador de casos puede accceder a unlock" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sivel2/usuarios/unlock"
      assert_redirected_to @raiz
    end

    test "observador puede acceder a editar su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sivel2/usuarios/edit"
      assert_response :ok
    end

    test "observador  puede acceder a put edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      put "/sivel2/usuarios/edit"
      assert_response :ok
    end

    test "observador  puede acceder a patch edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        patch "/sivel2/usuarios/" + id_usuario.to_s, params: {usuario: {nombre: "ale"}}
      end
    end


    test "observador no puede acceder a usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sivel2/usuarios"
      assert_redirected_to @raiz
    end

    test "observador no puede acceder a post usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post "/sivel2/usuarios", params: {usuario: {nombre: "ale"}}
      end
    end

    test "observador no debe presentar usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/nuevo"
      end
    end

    test "observador no debe mostrar usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/" + id_usuario.to_s
      end
    end

    test "observador no debe editar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/" + id_usuario.to_s + "/edita"
      end
    end

    test "observador no debe acceder a eliminar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        delete "/sivel2/usuarios/" + id_usuario.to_s
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista puede salir" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/sivel2/sign_out"
      assert_redirected_to @raiz
    end

    test "operador analista puede accceder a unlock new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/sivel2/usuarios/unlock/new"
      assert_redirected_to @raiz
    end

    test "operador analista puede accceder a unlock" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/sivel2/usuarios/unlock"
      assert_redirected_to @raiz
    end

    test "analista puede acceder a editar su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/sivel2/usuarios/edit"
      assert_response :ok
    end

    test "analista puede acceder a put edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      put "/sivel2/usuarios/edit"
      assert_response :ok
    end

    test "analista no puede acceder a usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/sivel2/usuarios"
      assert_redirected_to @raiz
    end

    test "analista no puede acceder a post usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post "/sivel2/usuarios", params: {usuario: {nombre: "ale"}}
      end
    end

    test "analista no debe presentar una usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/nuevo"
      end
    end

    test "analista no debe mostrar usuarios nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/" + id_usuario.to_s
      end
    end

    test "Analista no debe editar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        get "/sivel2/usuarios/" + id_usuario.to_s + "/edita"
      end
    end

    test "analista no debe acceder a eliminar usuarios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        delete "/sivel2/usuarios/" + id_usuario.to_s
      end
    end

    test "analista  puede acceder a patch edit su usuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      id_usuario = Sip::Usuario.take.id
      assert_raise CanCan::AccessDenied do
        patch "/sivel2/usuarios/" + id_usuario.to_s, params: {usuario: {nombre: "ale"}}
      end
    end

  end
end
