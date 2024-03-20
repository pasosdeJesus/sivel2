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
  CONFIG_HOSTS=www.example.com RUTA_RELATIVA=/ ${RAILS} test test/models test/controllers test/helpers
  if (test "$?" != "0") then {
    echo "No pasaron pruebas de regresión unitarias";
    exit 1;
  } fi;


  if (test -d test/integration -a "$SALTAINTEGRACION" != "1") then {
    CONFIG_HOSTS=www.example.com RUTA_RELATIVA=/ bin/rails test `find test/integration -name "*rb" -type f`
    if (test "$?" != "0") then {
      echo "No pasaron pruebas de integración";
      exit 1;
    } fi;
  } fi;

} fi;

echo "== PRUEBAS DE REGRESIÓN AL SISTEMA"
mkdir -p $rutaap/cobertura-sistema/
rm -rf $rutaap/cobertura-sistema/{*,.*}
if (test "$CI" = "" -a "$SALTACAPYBARA" != "1") then { # Por ahora no en gitlab-ci
  echo "== Con capybara $SALTACAPYBARA"
  (cd $rutaap; RUTA_RELATIVA="/" CONFIG_HOSTS=127.0.0.1 ${RAILS} msip:stimulus_motores test:system)
  if (test "$?" != "0") then {
    echo "No pasaron pruebas del sistema rails";
    exit 1;
  } fi;
} fi;

if (test -f $rutaap/bin/pruebasjs.sh -a "x$NOPRUEBAJS" != "x1") then {
  echo "== Con puppeteer"
  (cd $rutaap; ${RAILS} msip:stimulus_motores; IPDES=127.0.0.1 bin/pruebasjs.sh)
  if (test "$?" != "0") then {
    echo "No pasaron pruebas del sistema js";
    exit 1;
  } fi;
} fi;

echo "== Unificando resultados de pruebas en directorio clásico coverage"
mkdir -p coverage/
rm -rf coverage/{*,.*}

if (test "$rutaap" = "test/dummy/" -a "$RC" != "heb412_gen") then {
  ${RAILS} app:msip:reporteregresion
} else {
  ${RAILS} msip:reporteregresion
} fi;
r=$?
if (test "$r" != "0") then {
  exit $r;
} fi;

echo "== Copiando resultados para hacerlos visibles en el web en ruta cobertura"
# Copiar resultados para hacerlos visibles en web
mkdir -p $rutaap/public/${RUTA_RELATIVA}cobertura/
cp -rf coverage/* $rutaap/public/${RUTA_RELATIVA}cobertura/
cp -rf coverage/assets/* $rutaap/public/${RUTA_RELATIVA}assets/
