require 'test_helper'

module Msip
  class ControlAccesoAnexos < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @anexo_archivo = File.new("test/fixtures/sample_file.png")
      @anexo = Msip::Anexo.create(PRUEBA_ANEXO)
      @anexo.adjunto_file_name =  @anexo_archivo.path
      @anexo.save!
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
      skip
      assert_raise CanCan::AccessDenied do
        get descarga_anexo_path(@anexo.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe descargar anexo" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get descarga_anexo_path(@anexo.id)
      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [20]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe presentar listado" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      get ENV['RUTA_RELATIVA'] + "anexos/descarga_anexo/" + @anexo.id.to_s
      assert_response :ok
    end

    # Autenticado como operador con grupo Observador de Casos
    #######################################################

    def inicia_observador
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [21]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador observador debe presentar listado" do
      skip
      current_usuario = inicia_observador
      sign_in current_usuario
      get ENV['RUTA_RELATIVA'] + "anexos/descarga_anexo/" + @anexo.id.to_s
      assert_response :ok
    end
  end
end
