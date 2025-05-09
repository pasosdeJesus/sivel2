# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoAnexos < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      Rails.application.try(:reload_routes_unless_loaded)
      @anexo = Msip::Anexo.create(PRUEBA_ANEXO)
      @anexo.adjunto_file_name = "ej.txt"
      @anexo.save!
      n = format(
        Msip.ruta_anexos.to_s + "/%d_%s",
        @anexo.id.to_i,
        @anexo.adjunto_file_name,
      )
      FileUtils.touch(n)
    end

    teardown do
      if @anexo
        n = format(
          Msip.ruta_anexos.to_s + "/%d_%s",
          @anexo.id.to_i,
          @anexo.adjunto_file_name,
        )
        File.delete(n)
      end
    end

    PRUEBA_ANEXO = {
      descripcion: "grafica",
      adjunto_content_type: "image/png",
      adjunto_file_size: 33154,
      adjunto_updated_at: "2021-11-25",
      created_at: "2021-11-25",
      updated_at: "2021-11-25",
    }
    # No autenticado
    ################
    test "sin autenticar no debe poder descarga anexo" do
      assert_raise CanCan::AccessDenied do
        get msip.descarga_anexo_path(@anexo.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe descargar anexo" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.descarga_anexo_path(@anexo.id)

      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    test "autenticado como operador analista debe presentar listado" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_AN)
      sign_in current_usuario
      get msip.descarga_anexo_path(@anexo.id)

      assert_response :ok
    end

    # Autenticado como operador con grupo Observador de Casos
    #######################################################

    test "autenticado como operador observador debe presentar listado" do
      current_usuario = ::Usuario.find(PRUEBA_USUARIO_OBS)
      sign_in current_usuario
      get msip.descarga_anexo_path(@anexo.id)

      assert_response :ok
    end
  end
end
