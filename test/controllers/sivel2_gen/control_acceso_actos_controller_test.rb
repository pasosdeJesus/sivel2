# frozen_string_literal: true

require "test_helper"

module Sivel2Gen
  class ControlAccesoActosControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @casoacto = Sivel2Gen::Caso.create(PRUEBA_CASO)
      @pr = Sivel2Gen::Presponsable.find(39) # Polo estatal
      @cat = Sivel2Gen::Categoria.find(10) # Ejecución extrajudicial
      @persona = Msip::Persona.create(
        PRUEBA_PERSONA,
      )
      @victima = Sivel2Gen::Victima.create!(
        caso_id: @casoacto.id,
        persona_id: @persona.id,
      )

      @params = {
        caso: {
          fecha_localizada: "18/sep/2024",
          id: @casoacto.id,
          caso_presponsable_attributes: {
            "0" => {
              presponsable_id: @pr.id,
              categoria_ids: [@cat.id],
            },
          },
          victima_attributes: {
            "0" => {
              persona_attributes: {
                id: @persona.id,
              },
            },
          },
        },
        caso_acto_presponsable_id: [@pr.id],
        caso_acto_categoria_id: [@cat.id],
        caso_acto_persona_id: [@persona.id],
      }
      @raiz = Rails.application.config.relative_url_root
    end

    # No autenticado
    # Consulta pública de casos para usuarios no autenticados
    ################

    test "sin autenticar no puede agrega acto con turbo" do
      assert @casoacto.valid?
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_acto_path(@casoacto.id), params: @params, as: :turbo_stream
      end
    end

    test "sin autenticar no puede eliminar acto con turbo" do
      assert @casoacto.valid?
      acto = Sivel2Gen::Acto.create(
        caso_id: @casoacto.id,
        persona_id: @persona.id,
        categoria_id: @cat.id,
        presponsable_id: @pr.id,
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_acto_path(id: acto.id, index: 0)
      end
      @caso.destroy
    end

    # Autenticado como operador sin grupo
    #####################################

    test "Operados sin grupo no puede agrega acto con turbo" do
      Rails.application.try(:reload_routes_unless_loaded)

      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario

      assert @casoacto.valid?
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_acto_path(@casoacto.id), params: @params, as: :turbo_stream
      end
      @casoacto.destroy
    end

    test "Operador sin grupo no puede eliminar acto con turbo" do
      Rails.application.try(:reload_routes_unless_loaded)

      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario

      assert @casoacto.valid?
      acto = Sivel2Gen::Acto.create(
        caso_id: @casoacto.id,
        persona_id: @persona.id,
        categoria_id: @cat.id,
        presponsable_id: @pr.id,
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_acto_path(id: acto.id, index: 0)
      end
      @caso.destroy
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################
    test "Analista puede agregar, crear y eliminar acto con turbo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario

      assert @casoacto.valid?

      # crea acto
      assert_difference("Sivel2Gen::Acto.count", 1) do
        post sivel2_gen.crear_acto_path(@casoacto.id), params: @params, as: :turbo_stream
      end
      assert_response :success
      assert_match(/turbo-stream/, @response.body)

      # Buscar el acto recién creado
      acto_creado = Sivel2Gen::Acto.where(
        presponsable_id:
        @params[:caso_acto_presponsable_id].first,
        categoria_id:
        @params[:caso_acto_categoria_id].first,
        persona_id:
        @params[:caso_acto_persona_id].first,
        caso_id: @casoacto.id,
      ).first

      # Asegurarse de que el acto fue creado correctamente
      assert_not_nil acto_creado

      # Eliminar acto
      assert_difference("Sivel2Gen::Acto.count", -1) do
        delete sivel2_gen.eliminar_acto_path(@casoacto.id, acto_creado.id),
          as: :turbo_stream
      end
      assert_response :success
    end
  end
end
