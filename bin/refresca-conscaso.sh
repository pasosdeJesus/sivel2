#!/bin/sh
# Refresca sivel2_gen_conscaso cuando no hay otro refresco en curso
# vtamara@pasosdeJesus.org. 2020. Dominio público.

# Por agregar en crontab con algo como:
# 0 20 * *  * (cd /var/www/htdosc/sivel2/; doas bin/refresca-conscaso.sh >> /tmp/refresca.bitacora 2>&1)

if (test ! -f .env) then {
	echo 'Falata archivo .env'
	exit 1;
} fi;
. .env
if (test "$USUARIO_AP" = "") then {
	echo 'Falta USUARIO_AP en .env'
	exit 1;
} fi;
if (test ! -f config/database.yml) then {
	echo "Falta archivo config/database.yml"
	exit 1;
} fi;

bd=`grep -A2 production config/database.yml | grep database | sed -e "s/  database: //g"`
cl=`grep "password:" config/database.yml | sed -e "s/  password: //g"`
us=`grep "username:" config/database.yml | sed -e "s/  username: //g"`
ps axww | grep "[R]EFRESH" > /dev/null 2>&1
while (test "$?" = "0"); do
	echo "Refresco en curso, esperando 5 segundos"
	sleep 5;
	ps axww | grep "[R]EFRESH" > /dev/null 2>&1
done
doas su - ${USUARIO_AP} -c "psql -U $us -h /var/www/var/run/postgresql $bd -c 'REFRESH MATERIALIZED VIEW sivel2_gen_conscaso'"



