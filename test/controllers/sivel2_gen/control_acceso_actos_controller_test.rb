require 'test_helper'

module Sivel2Gen
  class ControlAccesoActosControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @raiz = Rails.application.config.relative_url_root
    end

    # No autenticado
    # Consulta pública de casos para usuarios no autenticados
    ################

    test "sin autenticar no puede agrega acto con turbo" do
      @casoacto = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoacto.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      persona = Msip::Persona.create(
        PRUEBA_PERSONA 
      )
      acto = Sivel2Gen::Acto.create(
        caso_id: @casoacto.id,
        persona_id: persona,
        categoria_id: cat.id,
        presponsable_id: pr.id
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_acto_path(@casoacto, acto, format: :turbo_stream)
      end
      @casoacto.destroy
    end

    test "sin autenticar no puede eliminar acto con turbo" do
      @casoacto = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoacto.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      persona = Msip::Persona.create(
        PRUEBA_PERSONA 
      )
      acto = Sivel2Gen::Acto.create(
        caso_id: @casoacto.id,
        persona_id: persona.id,
        categoria_id: cat.id,
        presponsable_id: pr.id
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_acto_path(id: acto.id, index: 0)
      end
      @caso.destroy
    end

    # Autenticado como operador sin grupo
    #####################################

    # Autenticado como operador con grupo Analista de Casos
    #######################################################


  end
end
