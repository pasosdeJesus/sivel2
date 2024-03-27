require 'test_helper'
require 'nokogiri'

module Mr519Gen
  class ControlAccesoPlanesencuestaControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      #@planencuesta = Mr519Gen::Planencuesta.create!(PRUEBA_PLANENCUESTA)
    end

    PRUEBA_PLANENCUESTA = {
      id: 10,
      campo_id: 1,
      valor: "eje",
      respuestafor_id: 2
    }

    # No autenticado
    ################

    test "sin autenticar no debe listar planesencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        get mr519_gen.planesencuesta_path
      end
    end

    test "sin autenticar no debe ver registro de un planencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        get mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "sin autenticar no debe ver vista de editar un planencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        get mr519_gen.edit_planencuesta_path(@planencuesta.id)
      end
    end

    test "sin autenticar no debe actualizar put un planencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        put mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "sin autenticar no debe actualizar patch  un planencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        patch mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "sin autenticar no debe eliminar un planencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "sin autenticar no debe postear planesencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        post mr519_gen.planesencuesta_path, params: {
          planencuesta: PRUEBA_PLANENCUESTA
        }
      end
    end

    test "sin autenticar no debe ver planencuesta de nuevo planencuesta" do
      skip
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_planencuesta_path()
      end
    end



    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo no debe presentar listado de planesencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.planesencuesta_path
      end
    end

    test "observador no debe postear planesencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post mr519_gen.planesencuesta_path, params: {
          planencuesta: PRUEBA_PLANENCUESTA
        }
      end
    end


    test "autenticado como operador sin grupo puede ver planencuesta de nuevo planencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_planencuesta_path()
      end
    end

    test "observador no debe ver registro de un planencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "observador no debe ver vista de editar un planencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.edit_planencuesta_path(@planencuesta.id)
      end
    end

    test "observador no debe actualizar put un planencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        put mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "observador no debe actualizar patch  un planencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        patch mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "observador no debe eliminar un planencuesta" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista no debe presentar listado de planesencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.planesencuesta_path
      end
    end

    test "operador analista no debe postear planesencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post mr519_gen.planesencuesta_path, params: {
          planencuesta: PRUEBA_PLANENCUESTA
        }
      end
    end

    test "autenticado como operador analista no debe presentar planencuesta de nuevo planencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.new_planencuesta_path()
      end
    end

    test "operador analista no debe ver registro de un planencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "operador analista no debe ver vista de editar un planencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get mr519_gen.edit_planencuesta_path(@planencuesta.id)
      end
    end

    test "operador analista no debe actualizar put un planencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        put mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "operador analista no debe actualizar patch  un planencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        patch mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

    test "operador analista no debe eliminar un planencuesta" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete mr519_gen.planencuesta_path(@planencuesta.id)
      end
    end

  end
end
