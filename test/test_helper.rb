# encoding: utf-8

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

PRUEBA_CASO = {
  titulo: "Caso de prueba",
  fecha: "2021-09-11",
  memo: "Una descripción del caso de prueba"
}
