require 'test_helper'

module Sivel2Gen
  class ControlAccesoVictimascolectivasControllerTest < ActionDispatch::IntegrationTest

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

    test "sin autenticar  no puede crear a victimas colectivas" do
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_victimacolectiva_path(caso: @caso, 
          index: @caso.victimacolectiva.size, format: :turbo_stream)
      end
    end

    test "sin autenticar  no puede eliminar victima colectiva" do
      @casovicol = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casovicol.valid?
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER 
      )
      vicol = Sivel2Gen::Victimacolectiva.create(
        grupoper_id: grupoper.id,
        caso_id: @casovicol.id 
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_victimacolectiva_path(id: vicol.id, index: 0)
      end
      @casovicol.destroy
    end
    # Autenticado como operador sin grupo
    #####################################

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

  end
end
