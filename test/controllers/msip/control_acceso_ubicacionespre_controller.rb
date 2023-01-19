require 'test_helper'

module Msip
  class ControlAccesoUbicacionespreControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @gupoper = Msip::Grupoper.create!(PRUEBA_GRUPOPER)
      @ubicacionpre = Msip::Ubicacionpre.create!(PRUEBA_UBICACIONPRE)
    end

    # No autenticado
    ################

    test "sin autenticar debe presentar listado" do
      get msip.ubicacionespre_path
      assert_response :ok
    end

    test "sin autenticar debe presentar resumen de existente" do
      get msip.ubicacionpre_path(@ubicacionpre.id)
      assert_response :ok
    end

    test "sin autenticar no debe ver formulario de nuevo" do
      assert_raise CanCan::AccessDenied do
        get msip.new_ubicacionpre_path()
      end
    end

    test "sin autenticar no debe crear" do
      assert_raise CanCan::AccessDenied do
        post msip.ubicacionespre_path, params: { 
          ubicacionpre: PRUEBA_UBICACIONPRE
        }
      end
    end

    test "sin autenticar no debe editar" do
      assert_raise CanCan::AccessDenied do
        get msip.edit_ubicacionpre_path(@ubicacionpre.id)
      end
    end

    test "sin autenticar no debe actualizar" do
      assert_raise CanCan::AccessDenied do
        patch msip.ubicacionpre_path(@ubicacionpre.id)
      end
    end

    test "sin autenticar no debe eliminar" do
      assert_raise CanCan::AccessDenied do
        delete msip.ubicacionpre_path(@ubicacionpre.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.ubicacionespre_path
      assert_response :ok
    end

    test "autenticado como operador sin grupo debe presentar resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.ubicacionpre_path(@ubicacionpre.id)
      assert_response :ok
    end

    test "autenticado como operador sin grupo no edita" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get msip.edit_ubicacionpre_path(@ubicacionpre.id)
      end
    end

    test "autenticaodo como operador no elimina" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete msip.ubicacionpre_path(@ubicacionpre.id)
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe presentar listado" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get msip.ubicacionespre_path
      assert_response :ok
    end

    test "autenticado como operador analista debe presentar resumen" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get msip.ubicacionpre_path(@ubicacionpre.id)
      assert_response :ok
    end

    test "autenticado como operador analista no debería poder editar" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get msip.edit_ubicacionpre_path(@ubicacionpre.id)
      end
    end

    test "autenticaodo como operador analista no debe eliminar" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete msip.ubicacionpre_path(@ubicacionpre.id)
      end
    end

  end
end
