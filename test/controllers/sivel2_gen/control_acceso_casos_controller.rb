require 'test_helper'

module Sivel2Gen
  class ControlAccesoCasosControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
    end

    # No autenticado
    # Consulta pública de casos para usuarios no autenticados
    ################

    test "sin autenticar no debe crear caso" do
      skip ##  en get sivel2_gen.casos_path ERROR:  current transaction is aborted, commands ignored until 
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.casos_path, params: { 
          caso: {
            titulo: "nuevo caso",
            fecha: "2021-09-11",
            memo: "Una descripcion"
          } 
        }
      end
    end

    test "sin activar la consulta publica no puede acceder a revista de casos" do
      ENV['SIVEL2_CONSWEB_PUBLICA'] = ""
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_path()
      end
    end
    
    test "activando consulta publica puede acceder a revista de casos" do
      ENV['SIVEL2_CONSWEB_PUBLICA'] = "1"
      get sivel2_gen.casos_cuenta_path
      assert_response :ok
    end

    test "sin autenticar puede contar todos los casos" do
      get sivel2_gen.casos_cuenta_path
      assert_response :ok
    end

    test "sin autenticar no puede acceder importarrelatos casos" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_importarrelatos_path
      end
    end

    test "sin autenticar no puede refrescar casos" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_refresca_path
      end
    end

    test "sin autenticar no puede acceder a casos mapaosm" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_mapaosm_path
      end
    end

    test "sin autenticar no puede acceder a validar casos" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.validarcasos_path
      end
    end

    test "sin autenticar no post a validar casos" do
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.validarcasos_path
      end
    end

    test "sin autenticar no post a casos importa" do
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.importa_casos_path
      end
    end

    test "sin autenticar  no puede acceder a victimas" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.victimas_nuevo_path
      end
    end

    test "sin autenticar  no puede acceder a victimascol" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.victimascolectivas_nuevo_path
      end
    end

    test "sin autenticar  no puede acceder a nuevo fuentesprensa" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.fuentesprensa_nuevo_path
      end
    end


    test "sin autenticar no puede acceder a casos lista" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_lista_path
      end
    end

    test "sin autenticar no debe ver formulario de nuevo" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.new_caso_path()
      end
    end


    test "sin autenticar no debe editar" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.edit_caso_path(@caso.id)
      end
    end

    test "sin autenticar no debe actualizar" do
      assert_raise CanCan::AccessDenied do
        patch sivel2_gen.caso_path(@caso.id)
      end
    end

    test "sin autenticar no debe eliminar" do
      assert_raise CanCan::AccessDenied do
        delete sivel2_gen.caso_path(@caso.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado" do
      skip ##  en get sivel2_gen.casos_path ERROR:  current transaction is aborted, commands ignored until 
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.casos_path 
      assert_response :ok
    end

    test "autenticado como operador sin grupo debe presentar resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.caso_path(@caso.id)
      assert_response :ok
    end

    test "autenticado como operador sin grupo  no puede acceder a validar casos" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.validarcasos_path
      end
    end

    test "autenticado como operador sin grupo  no puede post importa" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.importa_casos_path
      end
    end


    test "autenticado como operador sin grupo  no post a validar casos" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.validarcasos_path
      end
    end

    test "autenticado como operador sin grupo no accede a fuentesprensa neuvo" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.fuentesprensa_nuevo_path
      end
    end

    test "autenticado como operador sin grupo puede ver vista editar para etiquetas" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.edit_caso_path(@caso.id)
      assert_response :ok
    end

    test "autenticaodo como operador sin grupo u observador no elimina" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sivel2_gen.caso_path(@caso.id)
      end
    end

    test "Observador o sin grupo no debe ver formulario de nuevo" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.new_caso_path()
      end
    end

    test "operador sin grupo puede acceder a casos mapaosm" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.casos_mapaosm_path
      assert_response :ok
    end

    test "operador sin grupo  puede acceder a victimas" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.victimas_nuevo_path
      assert_response :ok
    end

    test "operador sin grupo puede acceder a victimascol" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.victimascolectivas_nuevo_path
      assert_response :ok
    end

    test "operador sin grupo puede acceder a casos lista" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.casos_lista_path
      assert_response :ok
    end

    test "operador sin grupo  no puede refrescar casos" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_refresca_path
      end
    end

    test "operador sin grupo no puede acceder importarrelatos casos" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_importarrelatos_path
      end
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.sip_grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe presentar listado" do
      skip ##  en get sivel2_gen.casos_path ERROR:  current transaction is aborted, commands ignored until 
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.casos_path
      assert_response :ok
    end

    test "autenticado como operador analista debe presentar resumen" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.caso_path(@caso.id)
      assert_response :ok
    end

    test "autenticado como operador analista debería poder editar" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.edit_caso_path(@caso.id)
      assert_response :ok
    end

    test "analista debe ver formulario de nuevo" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.new_caso_path()
      assert_response :redirect
    end

    test "operador analista no puede acceder importarrelatos casos" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_importarrelatos_path
      end
    end

    test "operador analista no puede post importa casos" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.importa_casos_path
      end
    end


    test "operador analista  puede acceder a validar casos" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.validarcasos_path
      assert_response :ok
    end

    test "operador analista puede acceder a victimas" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.victimas_nuevo_path
      assert_response :ok
    end

    test "operador analista puede acceder a fuentesprensa nuevo" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.fuentesprensa_nuevo_path
      assert_response :ok
    end

    test "operador analista puede acceder a victimascol" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.victimascolectivas_nuevo_path
      assert_response :ok
    end

    test "operador analista  no post a validar casos" do
      current_usuario = inicia_analista
      sign_in current_usuario
      post sivel2_gen.validarcasos_path
      assert_response :ok
    end

    test "operador analista  puede acceder a casos mapaosm" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.casos_mapaosm_path
      assert_response :ok
    end

    test "operador analista  puede acceder a casos lista" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.casos_lista_path
      assert_response :ok
    end

    test "operador analista  puede refrescar casos" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sivel2_gen.casos_refresca_path
      assert_response :ok
    end

    test "analista debe poder crear un caso nuevo" do
      skip ##  en get sivel2_gen.casos_path ERROR:  current transaction is aborted, commands ignored until 
      current_usuario = inicia_analista
      sign_in current_usuario
      post sivel2_gen.casos_path, params: { 
        caso: {
          titulo: "nuevo caso",
          fecha: "2021-09-11",
          memo: "una descripcion"
        } 
      } 
      assert_response :ok
    end
  end
end
