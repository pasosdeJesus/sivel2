# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module Msip
  class ControlAccesoBasicasControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      Rails.application.try(:reload_routes_unless_loaded)
      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @ope_sin_grupo = ::Usuario.find(PRUEBA_USUARIO_OP)
      @ope_analista = ::Usuario.find(PRUEBA_USUARIO_AN)
      @raiz = Rails.application.config.relative_url_root.delete_suffix("/")
    end

    test "sin autenticar no debe listar tablas básicas" do
      get msip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css("div#div_contenido").at_css("ul").count

      assert_equal(0, filas_index)
    end

    basicas_msip = Msip::Ability::BASICAS_PROPIAS

    ## PROBANDO BASICAS GEOGRÁFICAS
    PAIS_PARAMS = { id: 1, nombre: "ejemplo", nombreiso: "eje", fechacreacion: "2021-12-09" }
    MODELO_PARAMS = { nombre: "ejemplop", observaciones: "obs", fechacreacion: "2021-12-09" }
    MODELO_PARAMS_IDSTR = { id: "a", nombre: "ejemplop", observaciones: "obs", fechacreacion: "2021-12-09" }

    def crear_registro(modelo, basica)
      registro = if modelo.columns_hash["id"].type == "string".to_sym
        if basica == "trelacion"
          modelo.create!(MODELO_PARAMS_IDSTR.merge({ inverso: "a" }))
        else
          modelo.create!(MODELO_PARAMS_IDSTR)
        end
      else
        case basica
        when "centropoblado"
          modelo.create!(MODELO_PARAMS.merge({ municipio_id: 1360, cplocal_cod: 10000 }))
        when "departamento"
          modelo.create!(MODELO_PARAMS.merge({ pais_id: 170, deplocal_cod: 100000 }))
        when "municipio"
          modelo.create!(MODELO_PARAMS.merge({ departamento_id: 17, munlocal_cod: 10000 }))
        when "pais"
          modelo.create!(MODELO_PARAMS.merge({ id: 1000, nombreiso_espanol: "iso" }))
        when "tdocumento"
          modelo.create!(MODELO_PARAMS.merge({ sigla: "X" }))
        when "ubicacionpre"
          modelo.create!(MODELO_PARAMS.merge({
            pais_id: 170, departamento_id: 17, municipio_id: 1360,
          }))
        when "vereda"
          modelo.create!(MODELO_PARAMS.merge({ municipio_id: 1360 }))
        else
          modelo.create!(MODELO_PARAMS)
        end
      end
      registro
    end

    basicas_msip.each do |basica|
      if basica[1] == "oficina"
        next
      end

      modulo_str = basica[0] + "::" + basica[1].capitalize
      modelo = modulo_str.constantize

      # No autenticado

      if basica[1] == "centropoblado" || basica[1] == "municipio" || basica[1] == "departamento" || basica[1] == "pais" || basica[1] == "ubicacionpre"
        test "sin autenticar debe presentar el index de #{basica[1]}" do
          get @raiz + "/admin/#{basica[1].pluralize}"

          assert_response :ok
        end
        test "sin autenticar debe presentar el show de #{basica[1]}" do
          skip
          reg = modelo.all.take
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"

          assert_response :ok
        end
      else
        test "sin autenticar no debe presentar el index de #{basica[1]}" do
          assert_raise CanCan::AccessDenied do
            get @raiz + "/admin/#{basica[1].pluralize}"
          end
        end
        test "sin autenticar no debe presentar el show de #{basica[1]}" do
          reg = crear_registro(modelo, basica[1])
          assert_raise CanCan::AccessDenied do
            get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
          end
          reg.destroy!
        end
      end

      test "sin autenticar no debe ver formulario de nuevo de #{basica[1]}" do
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/nueva"
        end
      end

      test "sin autenticar no puede crear registro de #{basica[1]}" do
        ruta = @raiz + "/admin/#{basica[1].pluralize}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: { "#{basica[1]}": reg.attributes }
        end
        reg.destroy!
      end

      test "sin autenticar no debe editar #{basica[1]}" do
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}/edita"
        end
        reg.destroy!
      end

      test "sin autenticar no debe actualizar #{basica[1]}" do
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
      end

      test "sin autenticar no debe dejar destruir un registro de #{basica[1]}" do
        reg = crear_registro(modelo, basica[1])
        ruta1 = @raiz + "/admin/#{basica[1].pluralize}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
      end

      ##### Finaliza No autenticado #####

      # Autenticado como operador sin grupo

      if basica[1] == "centropoblado" || basica[1] == "municipio" || basica[1] == "departamento" || basica[1] == "pais" || basica[1] == "ubicacionpre"
        test "operador sin grupo debe presentar el index de #{basica[1]}" do
          sign_in @ope_sin_grupo
          get @raiz + "/admin/#{basica[1].pluralize}"

          assert_response :ok
        end
        test "operador sin grupo debe presentar el show de #{basica[1]}" do
          skip
          sign_in @ope_sin_grupo
          reg = modelo.all.take
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"

          assert_response :ok
        end
      else
        test "operador sin grupo no debe presentar el index de #{basica[1]}" do
          sign_in @ope_sin_grupo
          assert_raise CanCan::AccessDenied do
            get @raiz + "/admin/#{basica[1].pluralize}"
          end
        end
        test "operador sin grupo no debe presentar el show de #{basica[1]}" do
          sign_in @ope_sin_grupo
          reg = crear_registro(modelo, basica[1])
          assert_raise CanCan::AccessDenied do
            get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
          end
          reg.destroy!
        end
      end

      test "operador sin grupo no debe ver formulario de nuevo de #{basica[1]}" do
        sign_in @ope_sin_grupo
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/nueva"
        end
      end

      test "operador sin grupo no puede crear registro de #{basica[1]}" do
        sign_in @ope_sin_grupo
        ruta = @raiz + "/admin/#{basica[1].pluralize}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: { "#{basica[1]}": reg.attributes }
        end
        reg.destroy!
      end

      test "operador sin grupo no debe editar #{basica[1]}" do
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}/edita"
        end
        reg.destroy!
      end

      test "operador sin grupo no debe actualizar #{basica[1]}" do
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
      end

      test "oeprador sin grupo no debe dejar destruir un registro de #{basica[1]}" do
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        ruta1 = @raiz + "/admin/#{basica[1].pluralize}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
      end
      ##### Finaliza operador sin grupo #####

      # Autenticado como operador con grupo Analista de Casos

      if basica[1] == "centropoblado" || basica[1] == "municipio" || basica[1] == "departamento" || basica[1] == "pais" || basica[1] == "ubicacionpre"
        test "operador analista debe presentar el index de #{basica[1]}" do
          sign_in @ope_analista
          get @raiz + "/admin/#{basica[1].pluralize}"

          assert_response :ok
        end
        test "operador analista debe presentar el show de #{basica[1]}" do
          skip
          sign_in @ope_analista
          reg = modelo.all.take
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"

          assert_response :ok
        end
      else
        test "operador analista no debe presentar el index de #{basica[1]}" do
          sign_in @ope_analista
          assert_raise CanCan::AccessDenied do
            get @raiz + "/admin/#{basica[1].pluralize}"
          end
        end
        test "operador analista no debe presentar el show de #{basica[1]}" do
          sign_in @ope_analista
          reg = crear_registro(modelo, basica[1])
          assert_raise CanCan::AccessDenied do
            get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
          end
          reg.destroy!
        end
      end

      test "operador analista no debe ver formulario de nuevo de #{basica[1]}" do
        sign_in @ope_analista
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/nueva"
        end
      end

      test "operador analista no puede crear registro de #{basica[1]}" do
        sign_in @ope_analista
        ruta = @raiz + "/admin/#{basica[1].pluralize}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: { "#{basica[1]}": reg.attributes }
        end
        reg.destroy!
      end

      test "operador analista no debe editar #{basica[1]}" do
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}/edita"
        end
        reg.destroy!
      end

      test "operador analista no debe actualizar #{basica[1]}" do
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
      end

      test "oeprador analista no debe dejar destruir un registro de #{basica[1]}" do
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        ruta1 = @raiz + "/admin/#{basica[1].pluralize}" + "/" + reg.id.to_s
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
      filas_index = mih.at_css("div#div_contenido").at_css("ul").count

      assert_equal(0, filas_index)
    end

    test "autenticado como operador analista no debe presentar listado" do
      sign_in @ope_analista
      get msip.tablasbasicas_path
      mih = Nokogiri::HTML(@response.body)
      filas_index = mih.at_css("div#div_contenido").at_css("ul").count

      assert_equal(0, filas_index)
    end
  end
end
