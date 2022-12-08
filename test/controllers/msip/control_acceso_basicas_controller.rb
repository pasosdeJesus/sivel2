require 'test_helper'
require 'nokogiri'

module Msip
  class ControlAccesoBasicasControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @ope_sin_grupo = Usuario.create!(PRUEBA_USUARIO_OP)
      @ope_analista = inicia_analista
    end

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "sin autenticar no debe listar tablas básicas" do
      get msip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css('div#div_contenido').at_css('ul').count
      assert(filas_index == 0)
    end

    basicas_msip = Msip::Ability::BASICAS_PROPIAS

    ## PROBANDO BASICAS GEOGRÁFICAS
    PAIS_PARAMS = {id: 1, nombre: "ejemplo", nombreiso: "eje", fechacreacion: "2021-12-09"}
    MODELO_PARAMS = {nombre: "ejemplop",observaciones: "obs", fechacreacion: "2021-12-09"}
    MODELO_PARAMS_IDSTR = { id: "a", nombre: "ejemplop", observaciones: "obs", fechacreacion: "2021-12-09"}

    def crear_registro(modelo, basica)
      if modelo.columns_hash['id'].type == "string".to_sym
        if basica == 'trelacion'
          registro = modelo.create!(MODELO_PARAMS_IDSTR.merge({inverso: "a"}))
        else
          registro = modelo.create!(MODELO_PARAMS_IDSTR)
        end
      else
        case basica
        when "pais"
          registro = modelo.create!(MODELO_PARAMS.merge({id: 1000, nombreiso: "iso"}))
        when "departamento"
          registro = modelo.create!(MODELO_PARAMS.merge({id_pais: 170}))
        when "municipio"
          registro = modelo.create!(MODELO_PARAMS.merge({id_departamento: 17}))
        when "clase"
          registro = modelo.create!(MODELO_PARAMS.merge({id_municipio: 1360}))
        else
          registro = modelo.create!(MODELO_PARAMS)
        end
      end
      return registro
    end

    basicas_msip.each do |basica|
      if basica[1] == "oficina"
        next
      end

      modulo_str = basica[0] + "::" + basica[1].capitalize
      modelo = modulo_str.constantize()
      muestra = modelo.all.sample

      #No autenticado

      if basica[1] == "clase" || basica[1] == "municipio" || basica[1] == "departamento" || basica[1] == "pais"
        test "sin autenticar debe presentar el index de #{basica[1]}" do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
          assert_response :ok
        end
        test "sin autenticar debe presentar el show de #{basica[1]}" do
          skip 
          reg = modelo.all.take
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
          assert_response :ok
        end
      else 
        test "sin autenticar no debe presentar el index de #{basica[1]}" do
          assert_raise CanCan::AccessDenied do
            get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
          end
        end
        test "sin autenticar no debe presentar el show de #{basica[1]}" do
          reg = crear_registro(modelo, basica[1])
          assert_raise CanCan::AccessDenied do
            get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
          end
          reg.destroy!
        end
      end

      test "sin autenticar no debe ver formulario de nuevo de #{basica[1]}" do
        assert_raise CanCan::AccessDenied do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/nueva"
        end
      end

      test "sin autenticar no puede crear registro de #{basica[1]}" do
        ruta = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: {"#{basica[1]}": reg.attributes} 
        end
        reg.destroy!
      end

      test "sin autenticar no debe editar #{basica[1]}" do
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}/edita"
        end
        reg.destroy!
      end

      test "sin autenticar no debe actualizar #{basica[1]}" do
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
        end
        reg.destroy!
      end

      test "sin autenticar no debe dejar destruir un registro de #{basica[1]}" do
        reg = crear_registro(modelo, basica[1])
        ruta1 = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
      end

      ##### Finaliza No autenticado #####

      # Autenticado como operador sin grupo

      if basica[1] == "clase" || basica[1] == "municipio" || basica[1] == "departamento" || basica[1] == "pais"
        test "operador sin grupo debe presentar el index de #{basica[1]}" do
          sign_in @ope_sin_grupo
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
          assert_response :ok
        end
        test "operador sin grupo debe presentar el show de #{basica[1]}" do
          skip 
          sign_in @ope_sin_grupo
          reg = modelo.all.take
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
          assert_response :ok
        end
      else 
        test "operador sin grupo no debe presentar el index de #{basica[1]}" do
          sign_in @ope_sin_grupo
          assert_raise CanCan::AccessDenied do
            get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
          end
        end
        test "operador sin grupo no debe presentar el show de #{basica[1]}" do
          sign_in @ope_sin_grupo
          reg = crear_registro(modelo, basica[1])
          assert_raise CanCan::AccessDenied do
            get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
          end
          reg.destroy!
        end
      end

      test "operador sin grupo no debe ver formulario de nuevo de #{basica[1]}" do
        sign_in @ope_sin_grupo
        assert_raise CanCan::AccessDenied do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/nueva"
        end
      end

      test "operador sin grupo no puede crear registro de #{basica[1]}" do
        sign_in @ope_sin_grupo
        ruta = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: {"#{basica[1]}": reg.attributes} 
        end
        reg.destroy!
      end

      test "operador sin grupo no debe editar #{basica[1]}" do
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}/edita"
        end
        reg.destroy!
      end

      test "operador sin grupo no debe actualizar #{basica[1]}" do
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
        end
        reg.destroy!
      end

      test "oeprador sin grupo no debe dejar destruir un registro de #{basica[1]}" do
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        ruta1 = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
      end
      ##### Finaliza operador sin grupo #####

      # Autenticado como operador con grupo Analista de Casos

      if basica[1] == "clase" || basica[1] == "municipio" || basica[1] == "departamento" || basica[1] == "pais"
        test "operador analista debe presentar el index de #{basica[1]}" do
          sign_in @ope_analista
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
          assert_response :ok
        end
        test "operador analista debe presentar el show de #{basica[1]}" do
          skip 
          sign_in @ope_analista
          reg = modelo.all.take
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
          assert_response :ok
        end
      else 
        test "operador analista no debe presentar el index de #{basica[1]}" do
          sign_in @ope_analista
          assert_raise CanCan::AccessDenied do
            get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
          end
        end
        test "operador analista no debe presentar el show de #{basica[1]}" do
          sign_in @ope_analista
          reg = crear_registro(modelo, basica[1])
          assert_raise CanCan::AccessDenied do
            get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
          end
          reg.destroy!
        end
      end

      test "operador analista no debe ver formulario de nuevo de #{basica[1]}" do
        sign_in @ope_analista
        assert_raise CanCan::AccessDenied do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/nueva"
        end
      end

      test "operador analista no puede crear registro de #{basica[1]}" do
        sign_in @ope_analista
        ruta = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: {"#{basica[1]}": reg.attributes} 
        end
        reg.destroy!
      end

      test "operador analista no debe editar #{basica[1]}" do
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}/edita"
        end
        reg.destroy!
      end

      test "operador analista no debe actualizar #{basica[1]}" do
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}/#{reg.id}"
        end
        reg.destroy!
      end

      test "oeprador analista no debe dejar destruir un registro de #{basica[1]}" do
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        ruta1 = ENV['RUTA_RELATIVA'] + "admin/#{basica[1].pluralize()}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
      end

    end


    test "autenticado como operador sin grupo no debe presentar listado" do
      sign_in @ope_sin_grupo
      get msip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css('div#div_contenido').at_css('ul').count
      assert(filas_index == 0)
    end

    test "autenticado como operador analista no debe presentar listado" do
      sign_in @ope_analista
      get msip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css('div#div_contenido').at_css('ul').count
      assert(filas_index == 0)
    end



  end
end
