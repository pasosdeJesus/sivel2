require 'test_helper'

module Sivel2Gen
  class ControlAccesoCasoFotrasControllerTest < ActionDispatch::IntegrationTest

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

    test "sin autenticar no puede crear otras fuentes de prensa" do
      @casoofp = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoofp.valid?
      cof = Sivel2Gen::CasoFotra.create(
        caso_id: @casoofp.id,
        nombre: "otra fuente",
        fecha: '2023-01-11',
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_caso_fotra_path(@casoofp, cof, format: :turbo_stream)
      end
      cof.destroy
      @casoofp.destroy
    end

    test "sin autenticar  no puede eliminar otra fuente de prensa" do
      @casoofp = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoofp.valid?
      fotra = Sivel2Gen::Fotra.create(PRUEBA_FOTRA)
      caso_fotra = Sivel2Gen::CasoFotra.create(
        fotra_id: fotra.id,
        caso_id: @casoofp.id 
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_caso_fotra_path(id: caso_fotra.id, index: 0)
      end
      @casoofp.destroy
    end
    # Autenticado como operador sin grupo
    #####################################

    # Autenticado como operador con grupo Analista de Casos
    #######################################################


  end
end
