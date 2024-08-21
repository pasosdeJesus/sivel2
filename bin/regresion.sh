#!/bin/sh
# Inicializa base de prueba, corre 2 pruebas de regresión (test y test:system) 
# y finalmente genera reporte de cobertura mezclando resultados en 
# directorio coverage y publicandolo HTML en public/mimotor/cobertura

rutaap="./"
if (test -f "test/dummy/config/application.rb")  then {
  rutaap="test/dummy/"
} else {
  rutaap="./"
} fi;
echo "bin/regresion rutaap=$rutaap"
if (test -f $rutaap/.env) then {
  dirac=`pwd`
  cd $rutaap
  . ./.env
  cd $dirac
} else {
  echo "No existe $rutaap/.env";
  exit 1;
} fi;

vm=`ruby -v | sed  -e "s/^ruby \([0-9]\.[0-9]\).[0-9]* .*/\1/g"`
if (test "$vm" = "") then {
  echo "No se detectó versión de ruby"
  exit 1;
} fi;

RAILS="bin/rails"
if (test "$vm" = "3.2") then {
  RAILS="ruby --yjit bin/rails"
} fi;


if (test "$RUTA_RELATIVA" = "") then {
  echo "No leyó RUTA_RELATIVA de archivo .env"
  exit 1
} fi;

if (test "$SALTAPREPARA" != "1") then {
  echo "== Prepara base"

  (cd $rutaap;  ${RAILS} db:environment:set RAILS_ENV=test; RAILS_ENV=test ${RAILS} db:drop db:create db:setup db:seed msip:indices)
  if (test "$?" != "0") then {
    echo "No se pudo inicializar base de pruebas";
    exit 1;
  } fi;
} fi;

if (test "$SALTAUNITARIAS" != "1") then {
  echo "== Pruebas de regresión unitarias"
  mkdir -p cobertura-unitarias/
  rm -rf cobertura-unitarias/{*,.*}
  if (test -d test/models) then {
    RUTA_RELATIVA=/ ${RAILS} test test/models
    if (test "$?" != "0") then {
      echo "No pasaron pruebas de regresión unitarias a modelos";
      exit 1;
    } fi;
  } fi;
  if (test -d test/controllers) then {
    CONFIG_HOSTS=www.example.com RUTA_RELATIVA=/ ${RAILS} test test/controllers
    if (test "$?" != "0") then {
      echo "No pasaron pruebas de regresión unitarias a controladores";
      exit 1;
    } fi;
  } fi;
  if (test -d test/helpers) then {
    CONFIG_HOSTS=www.example.com RUTA_RELATIVA=/ ${RAILS} test test/helpers
    if (test "$?" != "0") then {
      echo "No pasaron pruebas de regresión unitarias a auxiliares";
      exit 1;
    } fi;
  } fi;
} fi;

if (test -d test/integration -a "$SALTAINTEGRACION" != "1") then {
  echo "== Pruebas de integración unitarias"
  for i in `find test/integration -name "*rb" -type f`; do
    echo $i;
    CONFIG_HOSTS=www.example.com RUTA_RELATIVA=/ bin/rails test $i
    if (test "$?" != "0") then {
      echo "No pasó prueba de integración $i";
      exit 1;
    } fi;
  done;
} fi;

# En adJ 7.5 no opera modo headless, ejecutar pruebasjs.sh manual y localmente
# https://gitlab.com/pasosdeJesus/adJ/-/issues/15
s=`uname`
if (test "$s" != "OpenBSD" -a -f $rutaap/bin/pruebasjs.sh -a -d $rutaap/test/puppeteer -a "x$NOPRUEBAJS" != "x1") then {
  echo "== Con puppeteer"
  (cd $rutaap; ${RAILS} msip:stimulus_motores; bin/pruebasjs.sh)
  if (test "$?" != "0") then {
    echo "No pasaron pruebas del sistema js";
    exit 1;
  } fi;
} fi;

echo "== Unificando resultados de pruebas en directorio clásico coverage"
mkdir -p coverage/
rm -rf coverage/{*,.*}

${RAILS} ${MSIP_REPORTEREGRESION}
r=$?
if (test "$r" != "0") then {
  exit $r;
} fi;


echo "== Copiando resultados para hacerlos visibles en el web en ruta cobertura"
# Copiar resultados para hacerlos visibles en web
mkdir -p $rutaap/public/${RUTA_RELATIVA}cobertura/
cp -rf coverage/* $rutaap/public/${RUTA_RELATIVA}cobertura/
cp -rf coverage/assets/* $rutaap/public/${RUTA_RELATIVA}assets/
