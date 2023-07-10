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
    ORIGEN_CORS=\"${ORIGEN_CORS}\" \
    PUERTOUNICORN=\"${PUERTOUNICORN}\" \
    RAILS_ENV=production \
    RUTA_RELATIVA=\"${RUTA_RELATIVA}\" \
    SECRET_KEY_BASE=\"${SECRET_KEY_BASE}\" \
    MSIP_FORMATO_FECHA=\"${MSIP_FORMATO_FECHA}\" \
    MSIP_RUTA_ANEXOS=\"${MSIP_RUTA_ANEXOS}\" \
    MSIP_RUTA_VOLCADOS=\"${MSIP_RUTA_VOLCADOS}\" \
    MSIP_TITULO=\"${MSIP_TITULO}\" \
    SIVEL2_CONSWEB_MAX=\"${SIVEL2_CONSWEB_MAX}\" \
    SIVEL2_CONSWEB_EPILOGO=\"${SIVEL2_CONSWEB_EPILOGO}\" \
    SIVEL2_CONSWEB_PIE=\"${SIVEL2_CONSWEB_PIE}\" \
    SIVEL2_CONSWEB_PUBLICA=\"${SIVEL2_CONSWEB_PUBLICA}\" \
    SIVEL2_MAPAOSM_DIASATRAS=\"${SIVEL2_MAPAOSM_DIASATRAS}\" \
    SIVEL2_MAPAOSM_LATINICIAL=\"${SIVEL2_MAPAOSM_LATINICIAL}\" \
    SIVEL2_MAPAOSM_LONGINICIAL=\"${SIVEL2_MAPAOSM_LONGINICIAL}\" \
    bundle exec unicorn_rails \
      -c ${DIRAP}/config/unicorn.conf.minimal.rb  -E production -D"
