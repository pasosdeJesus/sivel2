require 'test_helper'
require 'nokogiri'

module Mr519Gen
  class ControlAccesoOpcionescsControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @formulario = Mr519Gen::Formulario.create!(PRUEBA_FORMULARIO)
      @campo = Mr519Gen::Campo.create!(PRUEBA_CAMPO.merge(formulario_id: @formulario.id))
      @opcioncs = Mr519Gen::Opcioncs.create!(PRUEBA_OPCIONCS.merge(campo_id: @campo.id))
    end

    PRUEBA_FORMULARIO = {
      nombre: "formu ejemplo",
      nombreinterno: "formueje"
    }

    PRUEBA_OPCIONCS = {
      nombre: "opcioncs eje",
      valor: "valor"
    }

    PRUEBA_CAMPO = {
      nombre: "n",
      nombreinterno: "nn"
    }

    # No autenticado
    ################

    test "sin autenticar no debe acceder a opcionescs/new" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_opcioncs_path
      end
    end

    test "sin autenticar no debe eliminar opcioncs" do
      skip
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.opcioncs_path(@opcioncs.id)
      end
    end


    # Autenticado como operador sin grupo
    #####################################

    test "observador no debe acceder a opcionescs/new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_opcioncs_path
      end
    end

    test "observador no debe eliminar opcioncs" do
      skip
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.opcioncs_path(@opcioncs.id)
      end
    end


    # Autenticado como operador con grupo Analista de Casos
    #######################################################
    test "analista no debe acceder a opcionescs/new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_opcioncs_path
      end
    end

    test "analista no debe eliminar opcioncs" do
      skip
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.opcioncs_path(@opcioncs.id)
      end
    end

  end
end
