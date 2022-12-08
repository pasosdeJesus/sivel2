require 'test_helper'
require 'nokogiri'

module Heb412Gen
  class ControlAccesoPlantillahcmTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
    end

    PRUEBA_PLANTILLAHCM = { 
      id: 2,
      ruta: "plantillas/ReporteTabla.ods",
      fuente: "Pasos de Jesús",
      licencia: "Dominio Público",
      vista: "Caso",
      nombremenu: "Listado genérico de casos",
      filainicial: 6 }

    # No autenticado
    ################

    test "sin autenticar no debe listar plantillas hcm" do
      assert_raise CanCan::AccessDenied do
        get heb412_gen.plantillashcm_path
      end
    end

    test "sin autenticar no debe ver formulario de nueva plantilla hcm" do
      assert_raise CanCan::AccessDenied do
        get heb412_gen.new_plantillahcm_path()
      end
    end



    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado plamtillahcm" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get heb412_gen.plantillashcm_path
      assert_response :ok
    end

    test "autenticado como operador sin grupo puede ver resumen de plantillahcm" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "http://www.example.com:80#{ENV.fetch('RUTA_RELATIVA', '/sivel2/')}plantillahcm/#{Heb412Gen::Plantillahcm.all.sample.id}"
      assert_response :ok
    end

    test "autenticado como operador no debería poder editar plantillahcm" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get heb412_gen.edit_plantillahcm_path(Heb412Gen::Plantillahcm.all.sample.id)
      end
    end

    test "autenticado como operador no debe crear plantillahcm" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      skip
      assert_difference 'Heb412Gen::Plantillahcm.count' do
        plan = Heb412Gen::Plantillahcm.create!(PRUEBA_PLANTILLAHCM)
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

    test "autenticado como operador analista no debe presentar listado" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get heb412_gen.plantillashcm_path
      assert_response :ok
    end

    test "autenticado como operador analista debe presentar resumen de plantillahcm" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get "http://www.example.com:80#{ENV.fetch('RUTA_RELATIVA', '/sivel2/')}plantillahcm/#{Heb412Gen::Plantillahcm.all.sample.id}"
      assert_response :ok
    end

    test "autenticado como operador analista no debería poder editar plantillahcm" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get heb412_gen.edit_plantillahcm_path(Heb412Gen::Plantillahcm.all.sample.id)
      end
    end

  end
end
