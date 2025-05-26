# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module Mr519Gen
  class ControlAccesoCamposControllerTest < ActionDispatch::IntegrationTest
    # include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @formulario = Mr519Gen::Formulario.create!(PRUEBA_FORMULARIO)
    end

    PRUEBA_FORMULARIO = {
      nombre: "formu ejemplo",
      nombreinterno: "formueje",
    }

    PRUEBA_CAMPO = {
      nombre: "n",
      nombreinterno: "nn",
    }

    # No autenticado
    ################

    test "sin autenticar no debe acceder a campos/new" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_campo_path
      end
    end

    test "sin autenticar no debe eliminar campo" do
      skip
      @campo = Mr519Gen::Campo.create!(PRUEBA_CAMPO.merge(formulario_id: @formulario.id))
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.campo_path(@campo.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "observador no debe acceder a campos/new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_campo_path
      end
    end

    test "observador no debe eliminar campo" do
      skip
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @campo = Mr519Gen::Campo.create!(PRUEBA_CAMPO.merge(formulario_id: @formulario.id))
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.campo_path(@campo.id)
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################
    test "analista no debe acceder a campos/new" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_campo_path
      end
    end

    test "analista no debe eliminar campo" do
      skip
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      @campo = Mr519Gen::Campo.create!(PRUEBA_CAMPO.merge(formulario_id: @formulario.id))
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.campo_path(@campo.id)
      end
    end
  end
end
