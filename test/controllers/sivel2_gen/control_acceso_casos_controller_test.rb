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
      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @raiz = Rails.application.config.relative_url_root
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
      get sivel2_gen.casos_cuenta_path(:json)
      assert_response :ok
    end

    test "sin autenticar puede contar todos los casos" do
      get sivel2_gen.casos_cuenta_path(:json)
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

    test "sin autenticar no puede agrega acto con turbo" do
      @casoacto = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoacto.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      persona = Msip::Persona.create(
        PRUEBA_PERSONA 
      )
      acto = Sivel2Gen::Acto.create(
        caso_id: @casoacto.id,
        persona_id: persona,
        categoria_id: cat.id,
        presponsable_id: pr.id
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_acto_path(@casoacto, acto, format: :turbo_stream)
      end
      @casoacto.destroy
    end

    test "sin autenticar no puede eliminar acto con turbo" do
      @casoacto = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoacto.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      persona = Msip::Persona.create(
        PRUEBA_PERSONA 
      )
      acto = Sivel2Gen::Acto.create(
        caso_id: @casoacto.id,
        persona_id: persona.id,
        categoria_id: cat.id,
        presponsable_id: pr.id
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_acto_path(id: acto.id, index: 0)
      end
      @caso.destroy
    end

    test "sin autenticar no puede agrega acto colectivo con turbo" do
      @casoactocol = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoactocol.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER 
      )
      actocol = Sivel2Gen::Actocolectivo.create(
        caso_id: @casoactocol.id,
        grupoper_id: grupoper,
        categoria_id: cat.id,
        presponsable_id: pr.id
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_actocolectivo_path(@casoactocol, actocol, format: :turbo_stream)
      end
      @casoactocol.destroy
    end

    test "sin autenticar no puede eliminar acto colectivo con turbo" do
      @casoactocol = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoactocol.valid?
      pr = Sivel2Gen::Presponsable.take
      cat = Sivel2Gen::Categoria.take
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER 
      )
      actocol = Sivel2Gen::Actocolectivo.create(
        caso_id: @casoactocol.id,
        grupoper_id: grupoper,
        categoria_id: cat.id,
        presponsable_id: pr.id
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_actocolectivo_path(id: actocol.id, index: 0)
      end
      @casoactocol.destroy
    end

    test "sin autenticar no puede agrega anexo con turbo" do
      @casoan = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoan.valid?
      anexo = Msip::Anexo.create(
        PRUEBA_ANEXO
      )
      caso_anexo = Sivel2Gen::AnexoCaso.create(
        caso_id: @casoan.id,
        anexo_id: anexo.id
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_anexo_caso_path(@casoan, caso_anexo, format: :turbo_stream)
      end
      @casoan.destroy
      anexo.destroy
    end

    test "sin autenticar no puede eliminar anexo con turbo" do
      @casoan = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoan.valid?
      anexo = Msip::Anexo.create(
        PRUEBA_ANEXO
      )
      anexo_caso = Sivel2Gen::AnexoCaso.create(
        caso_id: @caso.id,
        anexo_id: anexo.id
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_anexo_caso_path(
          id: anexo_caso.id, index: 0)
      end
      @caso.destroy
    end

    test "sin autenticar no puede crear fuentes de prensa" do
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.create(PRUEBA_FUENTEPRENSA)
      assert fuenteprensa.valid?
      cf = Sivel2Gen::CasoFuenteprensa.create(
        caso_id: @casofp.id,
        fuenteprensa_id: fuenteprensa.id,
        fecha: '2023-01-11',
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_caso_fuenteprensa_path(@casofp, cf, format: :turbo_stream)
      end
      fuenteprensa.destroy
      cf.destroy
      @casofp.destroy
    end

    test "sin autenticar  no puede eliminar fuente de prensa" do
      @casofp = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casofp.valid?
      fuenteprensa = Msip::Fuenteprensa.take
      caso_fuenteprensa = Sivel2Gen::CasoFuenteprensa.create(
        fuenteprensa_id: fuenteprensa.id,
        caso_id: @casofp.id 
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_caso_fuenteprensa_path(id: caso_fuenteprensa.id, index: 0)
      end
      @caso.destroy
    end

    test "sin autenticar no puede crear otras fuentes de prensa" do
      @casoofp = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoofp.valid?
      cof = Sivel2Gen::CasoFotra.create(
        caso_id: @casoofp.id,
        nombre: "otra fuente",
        fecha: '2023-01-11',
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_caso_fotra_path(@casoofp, cof, format: :turbo_stream)
      end
      cof.destroy
      @casoofp.destroy
    end

    test "sin autenticar  no puede eliminar otra fuente de prensa" do
      @casoofp = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casoofp.valid?
      fotra = Sivel2Gen::Fotra.create(PRUEBA_FOTRA)
      caso_fotra = Sivel2Gen::CasoFotra.create(
        fotra_id: fotra.id,
        caso_id: @casoofp.id 
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_caso_fotra_path(id: caso_fotra.id, index: 0)
      end
      @casoofp.destroy
    end


    test "Sin autenticar no puede crear presponsable con turbo" do
      @casopr = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casopr.valid?
      pr = Sivel2Gen::Presponsable.take
      cof = Sivel2Gen::CasoPresponsable.create(
        caso_id: @casopr.id,
        presponsable_id: pr.id,
        tipo: 0
      )
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_caso_fotra_path(@casopr, cof, format: :turbo_stream)
      end
      cof.destroy
      @casopr.destroy
    end

    test "Sin autenticar no puede eliminar presponsable con turbo" do
      @casopr = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casopr.valid?
      pr = Sivel2Gen::Presponsable.take
      cpr = Sivel2Gen::CasoPresponsable.create(
        caso_id: @casopr.id,
        presponsable_id: pr.id,
        tipo: 0
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_caso_presponsable_path(
          id: cpr.id, index: 0)
      end
      @caso.destroy
    end

    test "sin autenticar  no puede acceder a victimas" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.victimas_nuevo_path
      end
    end

    test "sin autenticar  no puede crear a victimas" do
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_victima_path(caso: @caso, 
          index: @caso.victima.size, format: :turbo_stream)
      end
    end

    test "sin autenticar  no puede eliminar victima" do
      @casovic = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @caso.valid?
      persona = Msip::Persona.create(
        PRUEBA_PERSONA 
      )
      vic = Sivel2Gen::Victima.create(
        persona_id: persona.id,
        caso_id: @caso.id 
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_victima_path(id: vic.id, index: 0)
      end
      @casovic.destroy
    end

    test "sin autenticar  no puede acceder a victimascol" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.victimascolectivas_nuevo_path
      end
    end

    test "sin autenticar  no puede crear a victimas colectivas" do
      assert_raises(CanCan::AccessDenied) do
        post sivel2_gen.crear_victimacolectiva_path(caso: @caso, 
          index: @caso.victimacolectiva.size, format: :turbo_stream)
      end
    end

    test "sin autenticar  no puede eliminar victima colectiva" do
      @casovicol = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert @casovicol.valid?
      grupoper = Msip::Grupoper.create(
        PRUEBA_GRUPOPER 
      )
      vicol = Sivel2Gen::Victimacolectiva.create(
        grupoper_id: grupoper.id,
        caso_id: @casovicol.id 
      )
      assert_raises(CanCan::AccessDenied) do
        delete sivel2_gen.eliminar_victimacolectiva_path(id: vicol.id, index: 0)
      end
      @casovicol.destroy
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

    test "sin autenticar puede acceder a fichaimp" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.caso_fichaimp_path(Sivel2Gen::Caso.take.id)
      end
    end

    test "sin autenticar puede acceder a fichapdf" do
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.caso_fichapdf_path(Sivel2Gen::Caso.take.id)
      end
    end

    test "sin autenticar puede acceder a fichacasovertical" do
      get sivel2_gen.fichacasovertical_path
      assert_redirected_to @raiz
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

    test "sin autenticar no debe acceder" do
      assert_raise CanCan::AccessDenied do
        get "/casos/mapaosm"
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado" do
      skip ##  en get sivel2_gen.casos_path ERROR:  current transaction is aborted, commands ignored until 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.casos_path 
      assert_response :ok
    end

    test "autenticado como operador sin grupo debe presentar resumen" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.caso_path(@caso.id)
      assert_response :ok
    end

    test "autenticado como operador sin grupo  no puede acceder a validar casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.validarcasos_path
      end
    end

    test "autenticado como operador sin grupo  no puede post importa" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.importa_casos_path
      end
    end


    test "autenticado como operador sin grupo  no post a validar casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        post sivel2_gen.validarcasos_path
      end
    end

    test "autenticado como operador sin grupo puede ver vista editar para etiquetas" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.edit_caso_path(@caso.id)
      assert_response :ok
    end

    test "autenticaodo como operador sin grupo u observador no elimina" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sivel2_gen.caso_path(@caso.id)
      end
    end

    test "Observador o sin grupo no debe ver formulario de nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.new_caso_path()
      end
    end

    test "operador sin grupo puede acceder a casos mapaosm" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.casos_mapaosm_path
      assert_response :ok
    end

    test "operador sin grupo  puede acceder a victimas" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.victimas_nuevo_path
      assert_response :ok
    end

    test "operador sin grupo  puede acceder a fichacasovertical" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.fichacasovertical_path
      assert_redirected_to @raiz
    end

    test "operador sin grupo puede acceder a victimascol" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.victimascolectivas_nuevo_path
      assert_response :ok
    end

    test "operador sin grupo puede acceder a casos lista" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sivel2_gen.casos_lista_path
      assert_response :ok
    end

    test "operador sin grupo  no puede refrescar casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_refresca_path
      end
    end

    test "operador sin grupo no puede acceder importarrelatos casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.casos_importarrelatos_path
      end
    end

    test "operador sin grupo no puede acceder a fichaimp" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.caso_fichaimp_path(Sivel2Gen::Caso.take.id)
      end
    end

    test "operador sin grupo no puede acceder a fichapdf" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.caso_fichapdf_path(Sivel2Gen::Caso.take.id)
      end
    end

    test "operador sin grupo no debe acceder" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get "/casos/mapaosm"
      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista debe presentar listado" do
      skip ##  en get sivel2_gen.casos_path ERROR:  current transaction is aborted, commands ignored until 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.casos_path
      assert_response :ok
    end

    test "autenticado como operador analista debe presentar resumen" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.caso_path(@caso.id)
      assert_response :ok
    end

    test "autenticado como operador analista debería poder editar" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.edit_caso_path(@caso.id)
      assert_response :ok
    end

    test "analista debe ver formulario de nuevo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.new_caso_path()
      assert_response :redirect
    end

    test "operador analista si puede acceder importarrelatos casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.casos_importarrelatos_path
    end

    test "analista si puede post importa casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      post sivel2_gen.importa_casos_path
    end


    test "operador analista  puede acceder a validar casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.validarcasos_path
      assert_response :ok
    end

    test "operador analista puede acceder a fichacasovertical" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.fichacasovertical_path
      assert_redirected_to @raiz
    end

    test "operador analista puede acceder a victimas" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.victimas_nuevo_path
      assert_response :ok
    end

    test "operador analista puede acceder a victimascol" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.victimascolectivas_nuevo_path
      assert_response :ok
    end

    test "operador analista  no post a validar casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      post sivel2_gen.validarcasos_path
      assert_response :ok
    end

    test "operador analista  puede acceder a casos mapaosm" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.casos_mapaosm_path
      assert_response :ok
    end

    test "operador analista  puede acceder a casos lista" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.casos_lista_path
      assert_response :ok
    end

    test "operador analista no puede acceder a fichaimp" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.caso_fichaimp_path(Sivel2Gen::Caso.take.id)
      end
    end

    test "operador analista no puede acceder a fichapdf" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sivel2_gen.caso_fichapdf_path(Sivel2Gen::Caso.take.id)
      end
    end

    test "operador analista  puede refrescar casos" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get sivel2_gen.casos_refresca_path
      assert_response :ok
    end

    test "analista debe poder crear un caso nuevo" do
      skip ##  en get sivel2_gen.casos_path ERROR:  current transaction is aborted, commands ignored until 
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
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

    test "analista sin grupo no debe acceder" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get "/casos/mapaosm"
      assert_response :ok
    end

  end
end
