#!/bin/sh

f="$1"
if (test "$f" = "") then {
	echo "Falta fecha inical como primer parámetro" 
	exit 1;
} fi;
. .env


psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "DELETE FROM sivel2_gen_caso_usuario WHERE caso_id IN (SELECT id FROM sivel2_gen_caso WHERE fecha>='$f' AND TRIM(memo)='');"
psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "DELETE FROM msip_ubicacion WHERE caso_id IN (SELECT id FROM sivel2_gen_caso WHERE fecha>='$f' AND TRIM(memo)='');"
psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "DELETE FROM sivel2_gen_caso WHERE fecha>='$f' AND TRIM(memo)='';"
