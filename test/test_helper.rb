# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start("rails")
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

class ActiveSupport::TestCase
  if Msip::Tcentropoblado.all.count == 0
    load "#{Rails.root.join("db/seeds.rb")}"
    Sivel2::Application.load_tasks
    ActiveRecord::Base.connection.execute(<<-EOF)
      REFRESH MATERIALIZED VIEW msip_mundep;
    EOF

    Rake::Task["msip:indices"].invoke
  end

  protected

  def load_seeds
    load("#{Rails.root.join("db/seeds.rb")}")
  end
end

# Usuarios para pruebas sincronizados con db/seed.rb

PRUEBA_USUARIO_ADMIN = 1 # Usuario con rol administrador

PRUEBA_USUARIO_OP = 2 # Usuario con rol operador y sin grupo

PRUEBA_USUARIO_AN = 3 # Usuario operador del grupo analista de casos

PRUEBA_USUARIO_OBS = 4 # Usuario operador del grupo observador

PRUEBA_USUARIO_OBSPAR = 5 # Usuario operador del grupo observador de parte

PRUEBA_PERSONA = {
  nombres: "Luis Alejandro",
  apellidos: "Cruz Ordoñez",
  sexo: "M",
  numerodocumento: "1061769227",
}

PRUEBA_GRUPOPER = {
  id: 1,
  nombre: "grupoper1",
}

PRUEBA_ORGSOCIAL = {
  id: 1,
  grupoper_id: 1,
  created_at: "2021-08-27",
  updated_at: "2021-08-27",
}

PRUEBA_UBICACIONPRE = {
  nombre: "BARRANCOMINAS / BARRANCOMINAS / GUAINÍA / COLOMBIA",
  pais_id: 170,
  departamento_id: 56,
  municipio_id: 594,
  centropoblado_id: 13064,
  lugar: nil,
  sitio: nil,
  tsitio_id: nil,
  latitud: nil,
  longitud: nil,
  created_at: "2021-12-08",
  updated_at: "2021-12-08",
  nombre_sin_pais: "BARRANCOMINAS / BARRANCOMINAS / GUAINÍA",
}

PRUEBA_LUGARPRELIMINAR = {
  fecha: "2021-11-10",
  codigositio: "191030",
  created_at: "2021-11-06T19:39:08.247-05:00",
  updated_at: "2021-11-10T16:28:41.551-05:00",
  nombreusuario: "sivel2",
  organizacion: "organizacion ejemplo",
  ubicacionpre_id: nil,
  id_persona: 1,
  parentezco: "AB",
  grabacion: false,
  telefono: "35468489",
  tipotestigo_id: nil,
  otrotipotestigo: "",
  hechos: "",
  ubicaespecifica: "",
  disposicioncadaveres_id: nil,
  otradisposicioncadaveres: "",
  tipoentierro_id: nil,
  min_depositados: nil,
  max_depositados: nil,
  fechadis: nil,
  horadis: "1999-12-31T19:39:00.000-05:00",
  insitu: true,
  otrolubicacionpre_id: nil,
  detallesasesinato: "",
  nombrepropiedad: "",
  detallesdisposicion: "",
  nomcomoseconoce: "",
  elementopaisaje_id: nil,
  cobertura_id: nil,
  interatroprevias: "",
  interatroactuales: "",
  usoterprevios: "",
  usoteractuales: "",
  accesolugar: "",
  perfilestratigrafico: "",
  observaciones: "",
  procesoscul: "",
  desgenanomalia: "",
  evaluacionlugar: "",
  riesgosdanios: "",
  archivokml_id: nil,
}
PRUEBA_CASO = {
  titulo: "Caso de prueba",
  fecha: "2021-09-11",
  memo: "Una descripción del caso de prueba",
}
