require 'test_helper'

module Msip
  class ControlAccesoOrgsocialesControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers
    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
    end

    PRUEBA_BITACORA = {
      fecha: "2021-12-07",
      ip: "127.0.0.1",
      url: "ejemplo.com",
      params: "ejemplo params",
      modelo: "Ejemplo modelo",
      modelo_id: "1",
      operacion: "listar"

    }
    # No autenticado
    ################

    test "sin autenticar no debe presentar listado botacoras" do
      assert_raise CanCan::AccessDenied do
        get msip.bitacoras_path
      end
    end

    test "sin autenticar no debe presentar resumen de bitacora existente" do
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        get msip.bitacora_path(@bitacora.id)
      end
    end

    test "sin autenticar no debe ver formulario de nueva botacora" do
      assert_raise CanCan::AccessDenied do
        get msip.new_bitacora_path
      end
    end

    test "sin autenticar no debe crear bitacora" do
      assert_raise CanCan::AccessDenied do
        post msip.bitacoras_path, params: { 
          bitacora: PRUEBA_BITACORA }
      end
    end


    test "sin autenticar no debe editar bitacora" do
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        get msip.edit_bitacora_path(@bitacora.id)
      end
    end

    test "sin autenticar no debe actualizar bitacora" do
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        patch msip.bitacora_path(@bitacora.id)
      end
    end

    test "sin autenticar no debe eliminar bitacora" do
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        delete msip.bitacora_path(@bitacora.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado bitacoras" do
      skip 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get msip.bitacoras_path
      end
    end

    test "autenticado como operador sin grupo no debe presentar resumen bitacora" do
      skip 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        get msip.bitacora_path(@bitacora.id)
      end
    end

    test "autenticado como operador sin grupo no edita bitacora" do
      skip 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        get msip.edit_bitacora_path(@bitacora.id)
      end
    end

    test "autenticaodo como operador no elimina bitacora" do
      skip 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        delete msip.bitacora_path(@bitacora.id)
      end
      @bitacora.destroy!
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista no debepresentar listado bitacoras" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get msip.bitacoras_path
      assert_response :ok
    end

    test "autenticado como analista no debe presentar resumen bitacora" do
      skip 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      get msip.bitacora_path(@bitacora.id)
      assert_response :ok
      @bitacora.destroy!
    end

    test "autenticado como operador analista no debería poder editar bitacora" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        get msip.edit_bitacora_path(@bitacora.id)
      end
      @bitacora.destroy!
    end

    test "autenticaodo como operador analista no debe eliminar bitacora" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      @bitacora = Msip::Bitacora.create!(PRUEBA_BITACORA)
      assert_raise CanCan::AccessDenied do
        delete msip.bitacora_path(@bitacora.id)
      end
      @bitacora.destroy!

    end

  end
end
