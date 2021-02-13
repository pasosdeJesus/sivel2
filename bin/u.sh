#!/bin/sh
# Arranca con unicorn --suponiendo que ya se ejecutaron otras labores
#   necesarias para ejecutar como instalar gemas, generar recursos, 
#   actualizar indices, etc.  Ver bin/corre

if (test "${DIRAP}" = "") then {
  echo "Definir directorio de la aplicación en DIRAP"
  exit 1;
} fi;

if (test -f "${DIRAP}/.env") then {
  . $DIRAP/.env
} fi;

if (test "${SECRET_KEY_BASE}" = "") then {
  echo "Definir variable de ambiente SECRET_KEY_BASE"
  exit 1;
} fi;

if (test "${USUARIO_AP}" = "") then {
  echo "Definir usuario con el que se ejecuta en USUARIO_AP"
  exit 1;
} fi;

defuroot=""
if (test "${RAILS_RELATIVE_URL_ROOT}" != "") then {
  defuroot="RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT}"
} fi;

DOAS=`which doas 2> /dev/null`
if (test "$?" != "0") then {
  DOAS="sudo"
} fi;

$DOAS su - ${USUARIO_AP} -c "cd $DIRAP; 
  echo \"== Iniciando unicorn... ==\"; 
  ${defuroot} PUERTOUNICORN=${PUERTOUNICORN} CONFIG_HOSTS=${CONFIG_HOSTS}\
    DIRAP=$DIRAP RAILS_ENV=production SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    BD_CLAVE=${BD_CLAVE} BD_USUARIO=${BD_USUARIO} \
    BD_PRO=${BD_PRO} \
    RUTA_RELATIVA=${RUTA_RELATIVA} \
    HEB412_RUTA=${HEB412_RUTA} \
    bundle exec /usr/local/bin/unicorn_rails \
    -c $DIRAP/config/unicorn.conf.minimal.rb  -E production -D"

