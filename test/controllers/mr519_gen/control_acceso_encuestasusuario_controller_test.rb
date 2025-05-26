# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module Mr519Gen
  class ControlAccesoEncuestasusuarioCOntrollerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @formulario = Mr519Gen::Formulario.create!(PRUEBA_FORMULARIO)
      @respuestafor = Mr519Gen::Respuestafor.create!(PRUEBA_RESPUESTAFOR.merge({ formulario_id: @formulario.id }))
      @encuestausuario = Mr519Gen::Encuestausuario.create!(PRUEBA_ENCUESTAUSUARIO.merge({ respuestafor_id: @respuestafor.id }))
    end

    PRUEBA_FORMULARIO = {
      nombre: "formu ejemplo",
      nombreinterno: "formueje",
    }
    PRUEBA_ENCUESTAUSUARIO = {
      usuario_id: 1,
      fecha: "2021-12-21",
      fechainicio: "2021-12-21",
      fechafin: "2021-12-22",
    }

    PRUEBA_RESPUESTAFOR = {
      fechaini: "2021-12-21",
      fechacambio: "2021-12-22",
    }
    # No autenticado
    ################

    test "sin autenticar no debe listar encuestasusuario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.encuestasusuario_path
      end
    end

    test "sin autenticar no debe ver registro de un encuestausuario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.encuestausuario_path(@encuestausuario.id)
      end
    end

    test "sin autenticar no debe ver vista de editar un encuestausuario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.edit_encuestausuario_path(@encuestausuario.id)
      end
    end

    test "sin autenticar no debe actualizar put un encuestausuario" do
      assert_raise CanCan::AccessDenied do
        put mr519_gen.encuestausuario_path(@encuestausuario.id)
      end
    end

    test "sin autenticar no debe actualizar patch  un encuestausuario" do
      assert_raise CanCan::AccessDenied do
        patch mr519_gen.encuestausuario_path(@encuestausuario.id)
      end
    end

    test "sin autenticar no debe eliminar un encuestausuario" do
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.encuestausuario_path(@encuestausuario.id)
      end
    end

    test "sin autenticar no debe ver encuestausuario de nuevo encuestausuario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_encuestausuario_path
      end
    end

    test "sin autenticar no debe ver resultados de encuestausuario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.resultadosencuestausuario_path(@encuestausuario.id)
      end
    end

    test "sin autenticar no debe ver creartodousuario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.creartodousuario_path(@encuestausuario.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado de encuestasusuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get mr519_gen.encuestasusuario_path

      assert_response :ok
    end

    test "autenticado como operador sin grupo puede ver encuestausuario de nuevo encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_encuestausuario_path
      end
    end

    test "observador debe ver registro de un encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get mr519_gen.encuestausuario_path(@encuestausuario.id)

      assert_response :ok
    end

    test "observador debe ver vista de editar un encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get mr519_gen.edit_encuestausuario_path(@encuestausuario.id)

      assert_response :ok
    end

    test "observador no debe eliminar un encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.encuestausuario_path(@encuestausuario.id)
      end
    end

    test "observador no debe ver resultados de encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.resultadosencuestausuario_path(@encuestausuario.id)
      end
    end

    test "observador no debe ver creartodousuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.creartodousuario_path(@encuestausuario.id)
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista debe presentar listado de encuestasusuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get mr519_gen.encuestasusuario_path

      assert_response :ok
    end

    test "operador analista no debe postear encuestasusuario" do
      skip
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post mr519_gen.encuestasusuario_path, params: {
          encuestausuario: PRUEBA_ENCUESTAUSUARIO,
        }
      end
    end

    test "autenticado como operador analista debe presentar formulario de nuevo encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_encuestausuario_path
      end
    end

    test "operador analista no debe ver registro de un encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get mr519_gen.encuestausuario_path(@encuestausuario.id)

      assert_response :ok
    end

    test "operador analista debe ver vista de editar un encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get mr519_gen.edit_encuestausuario_path(@encuestausuario.id)

      assert_response :ok
    end

    test "operador analista no debe eliminar un encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.encuestausuario_path(@encuestausuario.id)
      end
    end

    test "analista debe ver resultados de encuestausuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.resultadosencuestausuario_path(@encuestausuario.id)
      end
    end

    test "analista debe ver creartodousuario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.creartodousuario_path(@encuestausuario.id)
      end
    end
  end
end
