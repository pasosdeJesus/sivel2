#!/bin/sh

# Refresca sivel2_gen_conscaso cuando no hay otro refresco en curso
# vtamara@pasosdeJesus.org. 2020. Dominio público.

# Por agregar en crontab con algo como:
# 0 20 * *  * (cd /var/www/htdosc/sivel2/; doas bin/refresca-conscaso.sh >> /tmp/refresca.bitacora 2>&1)

if (test ! -f .env) then {
  echo 'Falta archivo .env'
  exit 1;
} fi;
. .env
if (test "$USUARIO_AP" = "") then {
  echo 'Falta USUARIO_AP en .env'
  exit 1;
} fi;

ps axww | grep "[R]EFRESH" > /dev/null 2>&1
while (test "$?" = "0"); do
  echo "Refresco en curso, esperando 5 segundos"
  sleep 5;
  ps axww | grep "[R]EFRESH" > /dev/null 2>&1
done
cmd="doas su - ${USUARIO_AP} -c \"psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c 'REFRESH MATERIALIZED VIEW sivel2_gen_conscaso'\""
echo $cmd
eval $cmd



