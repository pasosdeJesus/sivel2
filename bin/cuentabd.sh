#!/bin/sh
# Cuenta registros por tabla en la base de datos

. .env

BD=$BD_DES
if (test "$RAILS_ENV" = "production") then {
  BD="$BD_PRO"
} fi;

# En esta variable queda resultado de ejecución de ordsql
export resordsql=""

function ordsql {
  ord=$@
  if (test "$ord" = "") then {
    echo "Faltan ordenes como parámetros de ordsql"
    ##exit 1;
  } fi;

  t1=`mktemp -p /tmp/ ordsqlXXXXXX`
  t2="$t1-res"
  echo "psql -h /var/www/var/run/postgresql -U $BD_USUARIO $BD <<EOF" > $t1
  echo "$ord" >> $t1
  echo "EOF" >> $t1
  chmod +x $t1
  $t1 > $t2
  res=$?
  resordsql=`cat $t2`
  return $res
}

ordsql '\\dt'
for tabla in `echo "$resordsql" | grep "public" | sed -e "s/.* public | \([^ ]*\) .*/\1/g"` ; do
  echo -n "$tabla "
  ordsql "SELECT COUNT(*) FROM public.$tabla;"
  echo $resordsql | grep row | sed -e "s/^[^0-9]*\([0-9][0-9]*\) .*/\1/g"
done

