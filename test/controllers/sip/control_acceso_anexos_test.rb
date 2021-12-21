require 'test_helper'

module Sip
  class ControlAccesoAnexos < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @anexo = Sip::Anexo.create(PRUEBA_ANEXO)
      @anexo.adjunto_file_name =  'ej.txt'
      @anexo.save!
      n = sprintf(Sip.ruta_anexos.to_s + "/%d_%s", @anexo.id.to_i, 
                  @anexo.adjunto_file_name)
      puts n
      FileUtils.touch n
    end

    teardown do
      if @anexo
        n = sprintf(Sip.ruta_anexos.to_s + "/%d_%s", @anexo.id.to_i, 
                    @anexo.adjunto_file_name)
        File.delete n
      end
    end

    PRUEBA_ANEXO= {
      descripcion: "grafica",
      adjunto_content_type: "image/png",
      adjunto_file_size: 33154,
      adjunto_updated_at: "2021-11-25",
      created_at: "2021-11-25",
      updated_at: "2021-11-25"
    }
    # No autenticado
    ################
    test "sin autenticar no debe poder descarga anexo" do
      assert_raise CanCan::AccessDenied do
        get sip.descarga_anexo_path(@anexo.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe descargar anexo" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sip.descarga_anexo_path(@anexo.id)
      assert_response :ok
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
      current_usuario = inicia_analista
      sign_in current_usuario
      get sip.descarga_anexo_path(@anexo.id)
      assert_response :ok
    end

    # Autenticado como operador con grupo Observador de Casos
    #######################################################

    def inicia_observador
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.sip_grupo_ids = [21]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador observador debe presentar listado" do
      current_usuario = inicia_observador
      sign_in current_usuario
      get sip.descarga_anexo_path(@anexo.id)
      assert_response :ok
    end
  end
end
