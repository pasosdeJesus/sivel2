require 'test_helper'

module Sivel2Gen
  class ControlAccesoActocolectivoscolectivosControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      #@actocolectivo = Sivel2Gen::Actocolectivo.create!(PRUEBA_ACTO.merge({id_caso: @caso.id, id_persona: @persona.id}))
      @ope_sin_grupo = Usuario.create!(PRUEBA_USUARIO_OP)
      @ope_analista = inicia_analista
    end

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    # No autenticado

    test "sin autenticar puede agregar actocolectivos" do
      assert_raise CanCan::AccessDenied do
        patch sivel2_gen.actoscolectivos_agregar_path
      end
    end

    test "sin autenticar no debe eliminar actocolectivo" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.actoscolectivos_eliminar_path
      end
    end

    # Autenticado como operador sin grupo

    test "operador sin grupo no  puede agregar actocolectivos" do
      sign_in @ope_sin_grupo 
      assert_raise CanCan::AccessDenied do
        patch sivel2_gen.actoscolectivos_agregar_path
      end
    end

    test "operador sin grupo  no debe eliminar actocolectivo" do
      sign_in @ope_sin_grupo 
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.actoscolectivos_eliminar_path
      end
    end

  end
end
