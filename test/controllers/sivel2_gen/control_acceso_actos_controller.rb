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
      @persona = Sip::Persona.create!(PRUEBA_PERSONA)
      @victima = Sivel2Gen::Victima.create!(id_persona: @persona.id, id_caso: @caso.id)
      @acto = Sivel2Gen::Acto.create!(PRUEBA_ACTO.merge({id_caso: @caso.id, id_persona: @persona.id}))
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

    test "sin autenticar puede agregar actos" do
      assert_raise CanCan::AccessDenied do
        patch sivel2_gen.actos_agregar_path
      end
    end

    test "sin autenticar no debe eliminar acto" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.actos_eliminar_path
      end
    end

    # Autenticado como operador sin grupo

    test "operador sin grupo no  puede agregar actos" do
      sign_in @ope_sin_grupo 
      assert_raise CanCan::AccessDenied do
        patch sivel2_gen.actos_agregar_path
      end
    end

    test "operador sin grupo  no debe eliminar acto" do
      sign_in @ope_sin_grupo 
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.actos_eliminar_path
      end
    end

  end
end
