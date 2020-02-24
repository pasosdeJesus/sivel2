# Refresca sivel2_gen_conscaso cuando no hay otro refresco en curso
# vtamara@pasosdeJesus.org. 2020. Dominio público.

if (test ! -f config/database.yml) then {
  echo "Falta archivo config/database.yml"
  exit 1;
} fi;

bd=`grep -A2 production config/database.yml | grep database | sed -e "s/  database: //g"`
cl=`grep "password:" config/database.yml | sed -e "s/  password: //g"`
us=`grep "username:" config/database.yml | sed -e "s/  username: //g"`
ps axww | grep "[R]EFRESH" > /dev/null 2>&1
while (test "$?" = "0"); do
  sleep 5;
  ps axww | grep "[R]EFRESH" > /dev/null 2>&1
done
psql -U $us -h /var/www/var/run/postgresql $bd



