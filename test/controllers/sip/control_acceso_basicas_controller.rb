require 'test_helper'
require 'nokogiri'

module Sip
  class ControlAccesoBasicasControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @persona = Sip::Persona.create!(PRUEBA_PERSONA)
    end

    test "sin autenticar no debe listar tablas básicas" do
      get sip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css('div#div_contenido').at_css('ul').count
      assert(filas_index == 0)
    end

    basicas_sip = Sip::Ability::BASICAS_PROPIAS
    
    basicas_sip.each do |basica|
      if basica[1] == "clase" || basica[1] == "municipio" || basica[1] == "departamento" || basica[1] == "pais"
        ## PROBANDO BASICAS GEOGRÁFICAS
        #No autenticado
        test "sin autenticar debe presentar el index de #{basica[1]}" do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
          assert_response :ok
        end

        test "sin autenticar debe presentar el show de #{basica[1]}" do
          skip
          ruta = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}" + "/1"
          get ruta 
          assert_response :ok
        end

        test "sin autenticar no puede crear registro de #{basica[1]}" do
          skip
          ruta = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}" + "/1"
          post ruta 
          assert_response :ok
        end

        test "sin autenticar no debe dejar destruir un registro de #{basica[1]}" do
          skip
          assert_difference("Sip::#{basica[1].capitalize()}.count", -1, 'registro destruid') do 
            delete :destroy, id: 1
          end
        end
      else

      end
    end

    #No autenticado
    ################

    test "sin autenticar no debe presentar listado de una tabla basica no geografica no propia" do
      assert_raise CanCan::AccessDenied do
        get sip.admin_tdocumentos_path
      end
    end

    test "sin autenticar no debe presentar listado de una tabla basica no geografica propia" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.admin_profesiones_path
      end
    end

    test "sin autenticar no debe presentar el show de una tabla basica no geografica" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.admin_profesion_path(Sivel2Gen::Profesion.all.sample.id)
      end
    end

    test "sin autenticar no debe presentar el show de una tabla basica no propia no geografica" do
      assert_raise CanCan::AccessDenied do
        get sip.admin_tdocumento_path(Sip::Tdocumento.last.id)
      end
    end
    test "sin autenticar no debe ver formulario de nuevo en una tabla básica" do
      assert_raise CanCan::AccessDenied do
        get sip.new_admin_municipio_path()
      end
    end

    test "sin autenticar no debe crear tabla basica" do
      assert_raise CanCan::AccessDenied do
        post sip.admin_tdocumentos_path, params: { 
          tdocumento: { 
            id: nil,
            nombres: "Tipo de documento nuevo",
            sigla: "TDN"
          }
        }
      end
    end

    test "sin autenticar no debe editar" do
      assert_raise CanCan::AccessDenied do
        get sip.edit_admin_tdocumento_path(Sip::Tdocumento.all.sample.id)
      end
    end

    test "sin autenticar no debe actualizar" do
      assert_raise CanCan::AccessDenied do
        patch sip.admin_tdocumento_path(Sip::Tdocumento.all.sample.id)
      end
    end

    test "sin autenticar no debe eliminar" do
      assert_raise CanCan::AccessDenied do
        delete sip.admin_tdocumento_path(Sip::Tdocumento.all.sample.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo no debe presentar listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css('div#div_contenido').at_css('ul').count
      assert(filas_index == 0)
    end

    test "autenticado como operador sin grupo no debe presentar resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.admin_profesion_path(Sivel2Gen::Profesion.all.sample.id)
      end
    end

    test "autenticado como operador sin grupo no edita" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.edit_admin_profesion_path(Sivel2Gen::Profesion.all.sample.id)
      end
    end

    test "autenticado como observador debe presentar resumen de una basica geografica" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sip.admin_municipio_path(Sip::Municipio.all.sample.id)
      assert_response :ok
    end

    test "autenticaodo como operador sin grupo u observador no elimina" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sivel2_gen.admin_profesion_path(Sivel2Gen::Profesion.all.sample.id)
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

    test "autenticado como operador analista no debe presentar listado" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css('div#div_contenido').at_css('ul').count
      assert(filas_index == 0)
    end

    test "autenticado como operador analista debe presentar resumen de una basica geografica" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.admin_municipio_path(Sip::Municipio.all.sample.id)
      assert_response :ok
    end

    test "autenticado como operador analista debe presentar index de una basica geografica" do
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.admin_municipios_path
      assert_response :ok
    end

    test "autenticado como operador analista no debería poder editar" do
      current_usuario = inicia_analista
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.edit_admin_municipio_path(Sip::Municipio.all.sample.id)
      end
    end

  end
end
