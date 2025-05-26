# frozen_string_literal: true

require "test_helper"

module Sivel2Gen
  class ControlAccesoActoscolectivosControllerTest < ActionDispatch::IntegrationTest
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

    test "sin autenticar no puede agrega acto colectivo con turbo" do
      @casoactocol = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casoactocol.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER,
      )
      actocol = Sivel2Gen::Actocolectivo.create(
        caso_id: @casoactocol.id,
        grupoper_id: grupoper,
        categoria_id: cat.id,
        presponsable_id: pr.id,
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_actocolectivo_path(@casoactocol, actocol, format: :turbo_stream)
      end
      @casoactocol.destroy
    end

    test "sin autenticar no puede eliminar acto colectivo con turbo" do
      @casoactocol = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casoactocol.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER,
      )
      actocol = Sivel2Gen::Actocolectivo.create(
        caso_id: @casoactocol.id,
        grupoper_id: grupoper,
        categoria_id: cat.id,
        presponsable_id: pr.id,
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_actocolectivo_path(id: actocol.id, index: 0)
      end
      @casoactocol.destroy
    end

    # Autenticado como operador sin grupo
    #####################################
    test "Operador sin grupo no puede agrega acto colectivo con turbo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @casoactocol = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casoactocol.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER,
      )
      actocol = Sivel2Gen::Actocolectivo.create(
        caso_id: @casoactocol.id,
        grupoper_id: grupoper,
        categoria_id: cat.id,
        presponsable_id: pr.id,
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_actocolectivo_path(@casoactocol, actocol, format: :turbo_stream)
      end
      @casoactocol.destroy
    end

    test "Operador sin grupo no puede eliminar acto colectivo con turbo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @casoactocol = Sivel2Gen::Caso.create(PRUEBA_CASO)

      assert @casoactocol.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER,
      )
      actocol = Sivel2Gen::Actocolectivo.create(
        caso_id: @casoactocol.id,
        grupoper_id: grupoper,
        categoria_id: cat.id,
        presponsable_id: pr.id,
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_actocolectivo_path(id: actocol.id, index: 0)
      end
      @casoactocol.destroy
    end
    # Autenticado como operador con grupo Analista de Casos
    #######################################################
  end
end
