#!/bin/sh

if (test ! -f .env) then {
  echo "Falta .env"
  exit 1;
} fi;
. .env

bd=$BD_DES
f=`date +%Y-%m-%d`
# Clave admin02
psql -U $BD_USUARIO $BD_DES -h /var/www/var/run/postgresql/ -c "INSERT INTO usuario (nusuario, nombre, rol, password, idioma, id, fechacreacion, fechadeshabilitacion, email, encrypted_password, created_at, updated_at) VALUES ('admin', 'Administrador@',1 ,'45bdfc3bf7e421561805fb56b59d577e', 'es_CO', 1, '2001-01-01', NULL, 'admin@localhost', '\$2a\$10\$IoDduXaph1kyQt0XIvFm0OmlMJeUAiMLAHalQZkPZVNkgZVF91G9.', '$f', '$f')"

