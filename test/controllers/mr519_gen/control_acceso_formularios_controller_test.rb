require 'test_helper'
require 'nokogiri'

module Mr519Gen
  class ControlAccesoFormulariosCOntrollerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @formulario = Mr519Gen::Formulario.create!(PRUEBA_FORMULARIO)
    end

    PRUEBA_FORMULARIO = {
      nombre: "formu ejemplo",
      nombreinterno: "formueje"
    }

    # No autenticado
    ################

    test "sin autenticar no debe listar formularios" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.formularios_path
      end
    end

    test "sin autenticar no debe ver registro de un formulario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "sin autenticar no debe ver vista de editar un formulario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.edit_formulario_path(@formulario.id)
      end
    end

    test "sin autenticar no debe actualizar put un formulario" do
      assert_raise CanCan::AccessDenied do
        put mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "sin autenticar no debe actualizar patch  un formulario" do
      assert_raise CanCan::AccessDenied do
        patch mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "sin autenticar no debe eliminar un formulario" do
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "sin autenticar no debe copiar un formulario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.copia_formulario_path(@formulario.id)
      end
    end

    test "sin autenticar no debe postear formularios" do
      assert_raise CanCan::AccessDenied do
        post mr519_gen.formularios_path, params: {
          formulario: PRUEBA_FORMULARIO
        }
      end
    end

    test "sin autenticar no debe ver formulario de nuevo formulario" do
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_formulario_path()
      end
    end



    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo no debe presentar listado de formularios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.formularios_path
      end
    end

    test "observador no debe postear formularios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post mr519_gen.formularios_path, params: {
          formulario: PRUEBA_FORMULARIO
        }
      end
    end


    test "autenticado como operador sin grupo puede ver formulario de nuevo formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_formulario_path()
      end
    end

    test "observador no debe ver registro de un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "observador no debe ver vista de editar un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.edit_formulario_path(@formulario.id)
      end
    end

    test "observador no debe actualizar put un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        put mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "observador no debe actualizar patch  un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        patch mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "observador no debe eliminar un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "observador no debe copiar un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.copia_formulario_path(@formulario.id)
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista no debe presentar listado de formularios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.formularios_path
      end
    end

    test "operador analista no debe postear formularios" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post mr519_gen.formularios_path, params: {
          formulario: PRUEBA_FORMULARIO
        }
      end
    end

    test "autenticado como operador analista no debe presentar formulario de nuevo formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_formulario_path()
      end
    end

    test "operador analista no debe ver registro de un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "operador analista no debe ver vista de editar un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.edit_formulario_path(@formulario.id)
      end
    end

    test "operador analista no debe actualizar put un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        put mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "operador analista no debe actualizar patch  un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        patch mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "operador analista no debe eliminar un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.formulario_path(@formulario.id)
      end
    end

    test "operador analista no debe copiar un formulario" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.copia_formulario_path(@formulario.id)
      end
    end
  end
end
