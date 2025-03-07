# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module Heb412Gen
  class ControlAccesoPlantillahcrTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @ruta = Rails.application.config.relative_url_root
    end

    PRUEBA_PLANTILLAHCR = {
      id: 2,
      ruta: "plantillas/ReporteTabla.ods",
      fuente: "Pasos de Jesús",
      licencia: "Dominio Público",
      vista: "Caso",
      nombremenu: "Registro genérico de casos",
    }

    # No autenticado
    ################

    test "sin autenticar no debe listar plantillas hcr" do
      assert_raise CanCan::AccessDenied do
        get heb412_gen.plantillashcr_path
      end
    end

    test "sin autenticar no debe ver formulario de nueva plantilla hcr" do
      assert_raise CanCan::AccessDenied do
        get heb412_gen.new_plantillahcr_path
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado plamtillahcr" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get heb412_gen.plantillashcr_path

      assert_response :ok
    end

    test "autenticado como operador sin grupo puede ver resumen de plantillahcr" do
      skip
      # get aquí produce NoMethodError: undefined method `id' for nil:NilClass
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "http://www.example.com:80#{@ruta}plantillahcr/#{Heb412Gen::Plantillahcr.all.sample.id}"

      assert_response :ok
    end

    test "autenticado como operador no debería poder editar plantillahcr" do
      skip
      # get aquí produce NoMethodError: undefined method `id' for nil:NilClass
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get heb412_gen.edit_plantillahcr_path(Heb412Gen::Plantillahcr.all.sample.id)
      end
    end

    test "autenticado como operador no debe crear plantillahcr" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      skip
      assert_difference "Heb412Gen::Plantillahcr.count" do
        Heb412Gen::Plantillahcr.create!(PRUEBA_PLANTILLAHCR)
      end
    end
    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista no debe presentar listado" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get heb412_gen.plantillashcr_path

      assert_response :ok
    end

    test "autenticado como operador analista debe presentar resumen de plantillahcr" do
      skip
      # get aquí produce NoMethodError: undefined method `id' for nil:NilClass
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "http://www.example.com:80#{@ruta}/plantillahcr/#{Heb412Gen::Plantillahcr.all.sample.id}"

      assert_response :ok
    end

    test "autenticado como operador analista no debería poder editar plantillahcr" do
      skip
      # get aquí produce NoMethodError: undefined method `id' for nil:NilClass
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get heb412_gen.edit_plantillahcr_path(Heb412Gen::Plantillahcr.all.sample.id)
      end
    end
  end
end
