require 'test_helper'

module Apo214
  class ControlAccesoLugarespreliminaresControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @persona = Sip::Persona.create!(PRUEBA_PERSONA)
      @lugarpreliminar = Apo214::Lugarpreliminar.create!(PRUEBA_LUGARPRELIMINAR)
    end

    # No autenticado
    ################

    test "sin autenticar no debe presentar listado de lugarespreliminares" do
      assert_raise CanCan::AccessDenied do
        get apo214.lugarespreliminares_path
      end
    end

    test "sin autenticar no debe presentar resumen de un lugarpreliminar" do
      assert_raise CanCan::AccessDenied do
        get apo214.lugarpreliminar_path(@lugarpreliminar.id)
      end
    end

    test "sin autenticar no debe ver formulario de nuevom lugarpreliminar" do
      assert_raise CanCan::AccessDenied do
        get apo214.new_lugarpreliminar_path
      end
    end

    test "sin autenticar no debe crear lugarprelimianr" do
      assert_raise CanCan::AccessDenied do
        post apo214.lugarespreliminares_path, params: { 
          lugarpreliminar: PRUEBA_LUGARPRELIMINAR
        }
      end
    end


    test "sin autenticar no debe editar lugarpreliminar" do
      assert_raise CanCan::AccessDenied do
        get apo214.edit_lugarpreliminar_path(@lugarpreliminar.id)
      end
    end

    test "sin autenticar no debe actualizar lugarpreliminar" do
      assert_raise CanCan::AccessDenied do
        patch apo214.lugarpreliminar_path(@lugarpreliminar.id)
      end
    end

    test "sin autenticar no debe eliminar lugarpreliminar" do
      assert_raise CanCan::AccessDenied do
        delete apo214.lugarpreliminar_path(@lugarpreliminar.id)
      end
    end


    test "autenticaodo como operador no elimina" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete apo214.lugarpreliminar_path(@lugarpreliminar.id)
      end
    end

  end
end
