#!/bin/sh
# Arranca con unicorn --suponiendo que ya se ejecutaron otras labores
#   necesarias para ejecutar como instalar gemas, generar recursos, 
#   actualizar índices, etc.  Ver bin/corre

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
  ${defuroot} BD_CLAVE='${BD_CLAVE}' \
    BD_PRO=\"${BD_PRO}\" \
    BD_USUARIO=\"${BD_USUARIO}\" \
    CONFIG_HOSTS=\"${CONFIG_HOSTS}\" \
    DIRAP=\"${DIRAP}\" \
    HEB412_RUTA=\"${HEB412_RUTA}\" \
    PUERTOUNICORN=\"${PUERTOUNICORN}\" \
    RAILS_ENV=production \
    RUTA_RELATIVA=\"${RUTA_RELATIVA}\" \
    SECRET_KEY_BASE=\"${SECRET_KEY_BASE}\" \
    SIP_FORMATO_FECHA=\"${SIP_FORMATO_FECHA}\" \
    SIP_RUTA_ANEXOS=\"${SIP_RUTA_ANEXOS}\" \
    SIP_RUTA_VOLCADOS=\"${SIP_RUTA_VOLCADOS}\" \
    SIP_TITULO=\"${SIP_TITULO}\" \
    SIVEL2_CONSWEB_MAX=\"${SIVEL2_CONSWEB_MAX}\" \
    SIVEL2_CONSWEB_EPILOGO=\"${SIVEL2_CONSWEB_EPILOGO}\" \
    SIVEL2_CONSWEB_PIE=\"${SIVEL2_CONSWEB_PIE}\" \
    SIVEL2_CONSWEB_PUBLICA=\"${SIVEL2_CONSWEB_PUBLICA}\" \
    SIVEL2_MAPAOSM_DIASATRAS=\"${SIVEL2_MAPAOSM_DIASATRAS}\" \
    bundle exec /usr/local/bin/unicorn_rails \
      -c ${DIRAP}/config/unicorn.conf.minimal.rb  -E production -D"

