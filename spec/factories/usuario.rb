FactoryGirl.define do
  factory :usuario do
    nusuario "admin"
    password "sjrven123"
    nombre "admin"
    descripcion "admin"
    rol 1
    idioma "es_CO"
    email "usuario1@localhost"
    encrypted_password '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G'
    sign_in_count 0
    fechacreacion "2014-08-05"
    fechadeshabilitacion nil
    regionsjr nil
  end
end

