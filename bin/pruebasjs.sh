#!/bin/sh
echo "=== Pruebas de regresión al sistema con Javascript"
# Para ejecutar en navegador visible ejecutar con
#  CONCABEZA=1 bin/pruebasjs

export IPDES=127.0.0.1
if (test "$RAILS_ENV" = "") then {
# Si ejecutamos en RAILS_ENV=test RUTA_RELATIVA será / por
# https://github.com/rails/rails/issues/49688
 	export RAILS_ENV=development
 	#export RAILS_ENV=test
} fi;
if (test "$CONFIG_HOSTS" = "") then {
	export CONFIG_HOSTS=127.0.0.1
} fi;

. ./.env
if (test "$PUERTOPRU" = "") then {
  export PUERTOPRU=33001;
} fi;
fstat | grep ":${PUERTOPRU}" 
if (test "$?" = "0") then {
  echo "Ya está corriendo un proceso en el puerto $PUERTOPRU, detengalo antes";
  exit 1;
} fi;
if (test ! -f .env) then {
  echo "Falta .env"
  exit 1;
} fi;

export PUERTODES=$PUERTOPRU
echo "IPDES=$IPDES"
echo "PUERTODES=$PUERTODES"

if (test "$IPDES" = "127.0.0.1") then {
	echo "=== Deteniendo"
	bin/detiene

  if (test "$SALTAPRECOMPILA" != "1") then {
    echo "=== Precompilando"
    echo "rm -rf public/${RUTA_RELATIVA}/assets/*"
    rm -rf public/${RUTA_RELATIVA}/assets/*
    bin/rails assets:precompile
  } fi;

	echo "=== Iniciando servidor"
	CONFIG_HOSTS=127.0.0.1 R=f bin/corre &
  CORRE_PID=$!
	sleep 5;
  echo "CORRE_PID=$CORRE_PID"
} fi;

if (test "$CORRE_PID" = "") then {
  echo "No pudo determinarse PID del proceso con el lado del servidor"
  exit 1;
} fi;
rps=`ps $CORRE_PID`
if (test "$?" != "0") then {
  echo "No arrancó proceso con el lado del servidor"
  exit 1;
} fi;
clrps=`echo $rps | wc -l | sed -e "s/ //g"`
if (test "$clrps" != "1") then {
  # 2 desde una terminal, 1 desde un script
  echo "Problema identificado proceso con el lado del servidor"
  echo "clrps=$clrps rps=$rps"
  exit 1;
} fi;

echo "***"
w3m -dump http://${IPDES}:${PUERTODES}/${RUTA_RELATIVA} | tee /tmp/salw3m
if (test "$?" != "0" -o  ! -s /tmp/salw3m) then {
  exit 1;
} fi;
echo "***"

cd test/puppeteer
yarn cache clean
yarn upgrade
yarn
t=0
np=0
for i in *-*.mjs; do
  echo "Ejecutando $i"
  node $i | tee /tmp/pruebasjs.bitacora
  te=`grep Tiempo /tmp/pruebasjs.bitacora | sed -e "s/.*: //g;s/ ms//g"`
  if (test "$?" = "0" -a "$te" != "") then {
    echo "OJO te=$te"
    t=`ruby -e "puts '$t'.to_f + '$te'.to_f"`
    echo "OJO t=$t"
    np=`expr $np + 1`
  } fi;
done

echo "Pruebas con medición de tiempo: $np"
echo "Tiempo total: $t"
prom=`ruby -e "puts $t / $np"`
echo "Promedio: $prom"
cd ../..
bin/detiene &

