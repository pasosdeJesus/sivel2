require 'test_helper'

module Sip
  class ControlAccesoRespaldo7z < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
    end

    # No autenticado
    ################

    test "sin autenticar no debe acceder a respaldo7z" do
      assert_raise CanCan::AccessDenied do
        get sip.respaldo7z_path
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "ope sin grupo no debe acceder a respaldo7z" do
      assert_raise CanCan::AccessDenied do
        get sip.respaldo7z_path
      end
    end


    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_ope(rol_id)
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.sip_grupo_ids = [rol_id]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe acceder a respaldo7z" do
      assert_raise CanCan::AccessDenied do
        current_usuario = inicia_ope(20)
        sign_in current_usuario
        get sip.respaldo7z_path
      end
    end

    # Autenticado como obeservador de casos
    #######################################################

    test "autenticado como observador debe presentar listado grupoper" do
      assert_raise CanCan::AccessDenied do
        current_usuario = inicia_ope(21)
        sign_in current_usuario
        get sip.respaldo7z_path
      end
    end

  end
end
