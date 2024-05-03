require 'test_helper'

module Sivel2Gen
  class ControlAccesoAnexoCasosControllerTest < ActionDispatch::IntegrationTest

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

    test "sin autenticar no puede agrega anexo con turbo" do
      @casoan = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoan.valid?
      anexo = Msip::Anexo.create(
        PRUEBA_ANEXO
      )
      caso_anexo = Sivel2Gen::AnexoCaso.create(
        caso_id: @casoan.id,
        anexo_id: anexo.id
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_anexo_caso_path(@casoan, caso_anexo, format: :turbo_stream)
      end
      @casoan.destroy
      anexo.destroy
    end

    test "sin autenticar no puede eliminar anexo con turbo" do
      @casoan = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoan.valid?
      anexo = Msip::Anexo.create(
        PRUEBA_ANEXO
      )
      anexo_caso = Sivel2Gen::AnexoCaso.create(
        caso_id: @caso.id,
        anexo_id: anexo.id
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_anexo_caso_path(
          id: anexo_caso.id, index: 0)
      end
      @caso.destroy
    end
    # Autenticado como operador sin grupo
    #####################################

    # Autenticado como operador con grupo Analista de Casos
    #######################################################


  end
end
