ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  fixtures :all
  
  protected
  def load_seeds
    load "#{Rails.root}/db/seeds.rb"
  end
end

# Usuario operador para ingresar y hacer pruebas
PRUEBA_USUARIO_OP = {
  nusuario: "operador",
  password: "sjrcol123",
  nombre: "operador",
  descripcion: "operador",
  rol: 5,
  idioma: "es_CO",
  email: "operador@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

# Usuario operador del grupo analista de casos 
# (debe agregarse al grupo analista de casos después de creado)
PRUEBA_USUARIO_AN = {
  nusuario: "analista",
  password: "sjrcol123",
  nombre: "analista",
  descripcion: "operador en grupo analista de casos",
  rol: 5,
  idioma: "es_CO",
  email: "analista@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}


PRUEBA_PERSONA = {
  nombres: 'Luis Alejandro',
  apellidos: 'Cruz Ordoñez',
  sexo: 'M',
  numerodocumento: '1061769227' 
}

PRUEBA_GRUPOPER = {
  id: 1,
  nombre: 'grupoper1'
}

PRUEBA_ORGSOCIAL = {
  id: 1,
  grupoper_id: 1,
  created_at: '2021-08-27',
  updated_at: '2021-08-27'
}

PRUEBA_UBICACIONPRE = {
  nombre: "BARRANCOMINAS / BARRANCOMINAS / GUAINÍA / COLOMBIA",
  pais_id: 170,
  departamento_id: 56,
  municipio_id: 594,
  clase_id: 13064,
  lugar: nil,
  sitio: nil,
  tsitio_id: nil,
  latitud: nil,
  longitud: nil,
  created_at: "2021-12-08",
  updated_at: "2021-12-08",
  nombre_sin_pais: "BARRANCOMINAS / BARRANCOMINAS / GUAINÍA"
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
  archivokml_id: nil
}
PRUEBA_CASO = {
  titulo: "Caso de prueba",
  fecha: "2021-09-11",
  memo: "Una descripción del caso de prueba"
}
