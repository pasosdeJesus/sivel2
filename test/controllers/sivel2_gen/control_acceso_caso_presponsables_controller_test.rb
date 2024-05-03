require 'test_helper'

module Sivel2Gen
  class ControlAccesoCasoPresponsablesControllerTest < ActionDispatch::IntegrationTest

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

    test "Sin autenticar no puede crear presponsable con turbo" do
      @casopr = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casopr.valid?
      pr = Sivel2Gen::Presponsable.take
      cof = Sivel2Gen::CasoPresponsable.create(
        caso_id: @casopr.id,
        presponsable_id: pr.id,
        tipo: 0
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_caso_fotra_path(@casopr, cof, format: :turbo_stream)
      end
      cof.destroy
      @casopr.destroy
    end

    test "Sin autenticar no puede eliminar presponsable con turbo" do
      @casopr = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casopr.valid?
      pr = Sivel2Gen::Presponsable.take
      cpr = Sivel2Gen::CasoPresponsable.create(
        caso_id: @casopr.id,
        presponsable_id: pr.id,
        tipo: 0
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_caso_presponsable_path(
          id: cpr.id, index: 0)
      end
      @caso.destroy
    end
    # Autenticado como operador sin grupo
    #####################################
    test "Operador sin grupo puede crear presponsable con turbo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @casopr = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casopr.valid?
      pr = Sivel2Gen::Presponsable.take
      cof = Sivel2Gen::CasoPresponsable.create(
        caso_id: @casopr.id,
        presponsable_id: pr.id,
        tipo: 0
      )
      post sivel2_gen.crear_caso_fotra_path(@casopr, cof, format: :turbo_stream)
      assert_response :success 
      cof.destroy
      @casopr.destroy
    end

    test "Operador sin grupo puede eliminar presponsable con turbo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      @casopr = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casopr.valid?
      pr = Sivel2Gen::Presponsable.take
      cpr = Sivel2Gen::CasoPresponsable.create(
        caso_id: @casopr.id,
        presponsable_id: pr.id,
        tipo: 0
      )
      delete sivel2_gen.eliminar_caso_presponsable_path(
        id: cpr.id, index: 0)
      assert_response :success 
      @caso.destroy
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################


  end
end
