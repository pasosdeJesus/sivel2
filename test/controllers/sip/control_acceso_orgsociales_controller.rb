require 'test_helper'

module Sip
  class ControlAccesoOrgsocialesControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @gupoper = Sip::Grupoper.create!(PRUEBA_GRUPOPER)
      @orgsocial = Sip::Orgsocial.create!(PRUEBA_ORGSOCIAL)
    end

    # No autenticado
    ################

    test "sin autenticar no debe presentar listado" do
      assert_raise CanCan::AccessDenied do
        get sip.orgsociales_path
      end
    end

    test "sin autenticar no debe presentar resumen de existente" do
      assert_raise CanCan::AccessDenied do
        get sip.orgsocial_path(@orgsocial.id)
      end
    end

    test "sin autenticar no debe ver formulario de nuevo" do
      assert_raise CanCan::AccessDenied do
        get sip.new_orgsocial_path()
      end
    end

    test "sin autenticar no debe crear" do
      assert_raise CanCan::AccessDenied do
        post sip.orgsociales_path, params: { 
          orgsocial: { 
            id: nil,
            grupoper_attributes: {
              id: nil,
              nombre: 'ZZ'
            }
          }
        }
      end
    end


    test "sin autenticar no debe editar" do
      assert_raise CanCan::AccessDenied do
        get sip.edit_orgsocial_path(@orgsocial.id)
      end
    end

    test "sin autenticar no debe actualizar" do
      assert_raise CanCan::AccessDenied do
        patch sip.orgsocial_path(@orgsocial.id)
      end
    end

    test "sin autenticar no debe eliminar" do
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sip.orgsociales_path
      assert_response :ok
    end

    test "autenticado como operador sin grupo debe presentar resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sip.orgsocial_path(@orgsocial.id)
      assert_response :ok
    end

    test "autenticado como operador sin grupo no edita" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.edit_orgsocial_path(@orgsocial.id)
      end
    end

    test "autenticaodo como operador no elimina" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
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

    test "autenticado como operador analista debe presentar listado" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.orgsociales_path
      assert_response :ok
    end

    test "autenticado como operador analista debe presentar resumen" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.orgsocial_path(@orgsocial.id)
      assert_response :ok
    end

    test "autenticado como operador analista debería poder editar" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.edit_orgsocial_path(@orgsocial.id)
    end

    test "autenticaodo como operador analista no debe eliminar" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end



  end
end
