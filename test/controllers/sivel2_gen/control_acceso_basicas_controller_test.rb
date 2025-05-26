# frozen_string_literal: true

require "test_helper"
require "nokogiri"

module Sivel2Gen
  class ControlAccesoBasicasControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

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

    basicas_sivel2_gen = Sivel2Gen::Ability::BASICAS_PROPIAS

    ## PROBANDO BASICAS GEOGRÁFICAS
    MODELO_PARAMS = { nombre: "ejemplop", observaciones: "obs", fechacreacion: "2021-12-09" }
    MODELO_PARAMS_IDSTR = { id: "z", nombre: "ejemplop", observaciones: "obs", fechacreacion: "2021-12-09" }

    def crear_registro(modelo, basica)
      registro = if modelo.columns_hash["id"].type == "string".to_sym
        case basica
        when "trelacion"
          modelo.create!(MODELO_PARAMS_IDSTR.merge({ inverso: "a" }))
        when "tviolencia"
          modelo.create!(MODELO_PARAMS_IDSTR.merge({ nomcorto: "nc" }))
        else
          modelo.create!(MODELO_PARAMS_IDSTR)
        end
      else
        case basica
        when "categoria"
          modelo.create!(MODELO_PARAMS.merge({ id: 1000, supracategoria_id: 9 }))
        when "pconsolidado"
          modelo.create!(MODELO_PARAMS.merge({ tipoviolencia: "D", clasificacion: "clas" }))
        when "intervalo"
          modelo.create!(MODELO_PARAMS.merge({ rango: "SIN INFORMACIÓN" }))
        when "supracategoria"
          modelo.create!(MODELO_PARAMS.merge({ id: 1360, tviolencia_id: "D" }))
        else
          if modelo.where(nombre: MODELO_PARAMS[:nombre]).count == 1
            modelo.find_by(nombre: MODELO_PARAMS[:nombre])
          else
            modelo.create!(MODELO_PARAMS)
          end
        end
      end
      registro
    end

    basicas_sivel2_gen.each do |basica|
      #[['Sivel2Gen', 'contexto']].each do |basica|
      if basica[1] == "estadocivil" || basica[1] == "maternidad" || basica[1] == "actividadoficio" || basica[1] == "escolaridad"

        next
      end

      modulo_str = basica[0] + "::" + basica[1].capitalize
      modelo = modulo_str.constantize
      # muestra = modelo.all.sample

      # No autenticado

      test "sin autenticar no debe presentar el index de #{basica[1]}" do
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}"
        end
        #  end

        puts "sin autenticar no debe presentar el show de #{basica[1]}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
        # end

        puts "sin autenticar no debe ver formulario de nuevo de #{basica[1]}"
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/nueva"
        end
        # end

        puts "sin autenticar no puede crear registro de #{basica[1]}"
        ruta = @raiz + "/admin/#{basica[1].pluralize}"
        # debugger
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: { "#{basica[1]}": reg.attributes }
        end
        reg.destroy!
        # end

        puts "sin autenticar no debe editar #{basica[1]}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}/edita"
        end
        reg.destroy!
        # end

        puts "sin autenticar no debe actualizar #{basica[1]}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
        # end

        puts "sin autenticar no debe dejar destruir un registro de #{basica[1]}"
        reg = crear_registro(modelo, basica[1])
        ruta1 = @raiz + "/admin/#{basica[1].pluralize}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
        # end

        ##### Finaliza No autenticado #####

        # Autenticado como operador sin grupo

        puts "operador sin grupo no debe presentar el index de #{basica[1]}"
        sign_in @ope_sin_grupo
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}"
        end
        # end

        puts "operador sin grupo no debe presentar el show de #{basica[1]}"
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
        # end

        puts "operador sin grupo no debe ver formulario de nuevo de #{basica[1]}"
        sign_in @ope_sin_grupo
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/nueva"
        end
        # end

        puts "operador sin grupo no puede crear registro de #{basica[1]}"
        sign_in @ope_sin_grupo
        ruta = @raiz + "/admin/#{basica[1].pluralize}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: { "#{basica[1]}": reg.attributes }
        end
        reg.destroy!
        # end

        puts "operador sin grupo no debe editar #{basica[1]}"
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}/edita"
        end
        reg.destroy!
        # end

        puts "operador sin grupo no debe actualizar #{basica[1]}"
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
        # end

        puts "oeprador sin grupo no debe dejar destruir un registro de #{basica[1]}"
        sign_in @ope_sin_grupo
        reg = crear_registro(modelo, basica[1])
        ruta1 = @raiz + "/admin/#{basica[1].pluralize}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
        # end
        ##### Finaliza operador sin grupo #####

        # Autenticado como operador con grupo Analista de Casos

        puts "operador analista no debe presentar el index de #{basica[1]}"
        sign_in @ope_analista
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}"
        end
        # end

        puts "operador analista no debe presentar el show de #{basica[1]}"
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
        # end

        puts "operador analista no debe ver formulario de nuevo de #{basica[1]}"
        sign_in @ope_analista
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/nueva"
        end
        # end

        puts "operador analista no puede crear registro de #{basica[1]}"
        sign_in @ope_analista
        ruta = @raiz + "/admin/#{basica[1].pluralize}"
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          post ruta, params: { "#{basica[1]}": reg.attributes }
        end
        reg.destroy!
        # end

        puts "operador analista no debe editar #{basica[1]}"
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          get @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}/edita"
        end
        reg.destroy!
        # end

        puts "operador analista no debe actualizar #{basica[1]}"
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        assert_raise CanCan::AccessDenied do
          patch @raiz + "/admin/#{basica[1].pluralize}/#{reg.id}"
        end
        reg.destroy!
        # end

        puts "oeprador analista no debe dejar destruir un registro de #{basica[1]}"
        sign_in @ope_analista
        reg = crear_registro(modelo, basica[1])
        ruta1 = @raiz + "/admin/#{basica[1].pluralize}" + "/" + reg.id.to_s
        assert_raise CanCan::AccessDenied do
          delete ruta1
        end
        reg.destroy!
      end

      # debugger
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
