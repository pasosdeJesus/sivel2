require 'test_helper'

module Sivel2Gen
  class ControlAccesoCasofotrasControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @ope_sin_grupo = Usuario.create!(PRUEBA_USUARIO_OP)
      @ope_analista = inicia_analista
    end

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.sip_grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    PRUEBA_ACTO = {
      id_presponsable: 28,
      id_categoria: 77,
    }

    # No autenticado

    test "sin autenticar puede crear nuevo casofotras" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casofotras_nuevo_path
      end
    end

    # Autenticado como operador sin grupo

    test "operador sin grupo no  puede crear casofotras" do
      sign_in @ope_sin_grupo
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casofotras_nuevo_path
      end
    end

    # Autenticado como analista

    test "analista no puede crear casofotras" do
      sign_in @ope_analista
      get sivel2_gen.casofotras_nuevo_path + "?caso_id=#{@caso.id}"
      assert_response :ok
    end

  end
end
