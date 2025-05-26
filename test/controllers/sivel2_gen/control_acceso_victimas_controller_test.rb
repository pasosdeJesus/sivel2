# frozen_string_literal: true

require "test_helper"

module Sivel2Gen
  class ControlAccesoVictimasControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @raiz = Rails.application.config.relative_url_root
    end

    # No autenticado
    # Consulta pública de casos para usuarios no autenticados
    ################

    test "sin autenticar  no puede crear a victimas" do
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_victima_path(
          caso: @caso,
          index: @caso.victima.size,
          format: :turbo_stream,
        )
      end
    end

    test "sin autenticar  no puede eliminar victima" do
      @casovic = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @caso.valid?
      persona = Msip::Persona.create(
        PRUEBA_PERSONA,
      )
      vic = Sivel2Gen::Victima.create(
        persona_id: persona.id,
        caso_id: @caso.id,
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_victima_path(id: vic.id, index: 0)
      end
      @casovic.destroy
    end
    # Autenticado como operador sin grupo
    #####################################
    test "Operador sin grupo puede crear a victimas" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      post sivel2_gen.crear_victima_path(
        caso: @caso,
        index: @caso.victima.size,
        format: :turbo_stream,
      )

      assert_response :success
    end

    test "Operador sin grupo puede eliminar victima" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @casovic = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @caso.valid?
      persona = Msip::Persona.create(
        PRUEBA_PERSONA,
      )
      vic = Sivel2Gen::Victima.create(
        persona_id: persona.id,
        caso_id: @caso.id,
      )
      delete sivel2_gen.eliminar_victima_path(id: vic.id, index: 0)

      assert_response :success
      @casovic.destroy
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################
    test "Analista puede crear a victimas" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      post sivel2_gen.crear_victima_path(
        caso: @caso,
        index: @caso.victima.size,
        format: :turbo_stream,
      )

      assert_response :success
    end

    test "Analista puede eliminar victima" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      @casovic = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @caso.valid?
      persona = Msip::Persona.create(
        PRUEBA_PERSONA,
      )
      vic = Sivel2Gen::Victima.create(
        persona_id: persona.id,
        caso_id: @caso.id,
      )
      delete sivel2_gen.eliminar_victima_path(id: vic.id, index: 0)

      assert_response :success
      @casovic.destroy
    end
  end
end
