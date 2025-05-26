# frozen_string_literal: true

require "test_helper"

module Sivel2Gen
  class ControlAccesoCasoFuentesprensaControllerTest < ActionDispatch::IntegrationTest
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

    test "sin autenticar no puede crear fuentes de prensa" do
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.create(PRUEBA_FUENTEPRENSA)

      assert fuenteprensa.valid?
      cf = Sivel2Gen::CasoFuenteprensa.create(
        caso_id: @casofp.id,
        fuenteprensa_id: fuenteprensa.id,
        fecha: "2023-01-11",
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_caso_fuenteprensa_path(@casofp, cf, format: :turbo_stream)
      end
      fuenteprensa.destroy
      cf.destroy
      @casofp.destroy
    end

    test "sin autenticar  no puede eliminar fuente de prensa" do
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.take
      caso_fuenteprensa = Sivel2Gen::CasoFuenteprensa.create(
        fuenteprensa_id: fuenteprensa.id,
        caso_id: @casofp.id,
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_caso_fuenteprensa_path(id: caso_fuenteprensa.id, index: 0)
      end
      @caso.destroy
    end

    # Autenticado como operador sin grupo
    #####################################
    test "Operador sin grupo puede crear fuentes de prensa" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.create(PRUEBA_FUENTEPRENSA)

      assert fuenteprensa.valid?
      cf = Sivel2Gen::CasoFuenteprensa.create(
        caso_id: @casofp.id,
        fuenteprensa_id: fuenteprensa.id,
        fecha: "2023-01-11",
      )
      post sivel2_gen.crear_caso_fuenteprensa_path(@casofp, cf, format: :turbo_stream)

      assert_response :success
      fuenteprensa.destroy
      cf.destroy
      @casofp.destroy
    end

    test "Operador sin grupo no puede eliminar fuente de prensa" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.take
      caso_fuenteprensa = Sivel2Gen::CasoFuenteprensa.create(
        fuenteprensa_id: fuenteprensa.id,
        caso_id: @casofp.id,
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_caso_fuenteprensa_path(id: caso_fuenteprensa.id, index: 0)
      end
      @caso.destroy
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################
    test "Analista puede crear fuentes de prensa" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.create(PRUEBA_FUENTEPRENSA)

      assert fuenteprensa.valid?
      cf = Sivel2Gen::CasoFuenteprensa.create(
        caso_id: @casofp.id,
        fuenteprensa_id: fuenteprensa.id,
        fecha: "2023-01-11",
      )
      post sivel2_gen.crear_caso_fuenteprensa_path(@casofp, cf, format: :turbo_stream)

      assert_response :success
      fuenteprensa.destroy
      cf.destroy
      @casofp.destroy
    end

    test "Analista puede eliminar fuente de prensa" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.take
      caso_fuenteprensa = Sivel2Gen::CasoFuenteprensa.create(
        fuenteprensa_id: fuenteprensa.id,
        caso_id: @casofp.id,
      )
      delete sivel2_gen.eliminar_caso_fuenteprensa_path(id: caso_fuenteprensa.id, index: 0)

      assert_response :success
      @caso.destroy
    end
  end
end
