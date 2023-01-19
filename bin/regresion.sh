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
if (test -f $rutaap/.env) then {
  dirac=`pwd`
  cd $rutaap
  . ./.env
  cd $dirac
} else {
  echo "No existe $rutaap/.env";
} fi;

if (test "$RUTA_RELATIVA" = "") then {
  echo "No leyó RUTA_RELATIVA de archivo .env"
  exit 1
} fi;

echo "== Prepara"
(cd $rutaap; RAILS_ENV=test bin/rails db:drop db:setup db:seed msip:indices)
if (test "$?" != "0") then {
  echo "No puede preparse base de prueba";
  exit 1;
} fi;

echo "== Prepara entorno"

vm=`ruby -v | sed  -e "s/^ruby \([0-9]\.[0-9]\).[0-9]* .*/\1/g"`
if (test "$vm" = "") then {
  echo "No se detectó versión de ruby"
  exit 1;
} fi;

RAILS="bin/rails"
if (test "$vm" = "3.2") then {
  RAILS="ruby --yjit bin/rails"
} fi;

if (test -f "test/dummy/config/application.rb") then {
  (cd test/dummy; ${RAILS} db:environment:set RAILS_ENV=test; RAILS_ENV=test ${RAILS} db:drop db:create db:setup db:seed msip:indices)
} else {
  ${RAILS} db:environment:set RAILS_ENV=test; 
  RAILS_ENV=test ${RAILS} db:drop db:create db:setup db:seed msip:indices
} fi;

echo "== Pruebas de regresión unitarias"
mkdir -p cobertura-unitarias/
rm -rf cobertura-unitarias/{*,.*}
CONFIG_HOSTS=www.example.com ${RAILS} test

echo "== Pruebas de regresión al sistema"
if (test -f "test/dummy/config/application.rb") then {
  mkdir -p test/dummy/cobertura-sistema/
  rm -rf test/dummy/cobertura-sistema/{*,.*}
  if (test "$CI" = "") then { # Por ahora no en gitlab-ci
    (cd test/dummy; CONFIG_HOSTS=127.0.0.1 ${RAILS} msip:stimulus_motores test:system)
  } fi;
  if (test -f test/dummy/bin/pruebasjs) then {
    (cd test/dummy; CONFIG_HOSTS=127.0.0.1 ${RAILS} msip:stimulus_motores; bin/pruebasjs)
  } fi;
} else {
  mkdir -p cobertura-sistema/
  rm -rf cobertura-sistema/{*,.*}
  if (test "$CI" = "") then { # Por ahora no en gitlab-ci
    CONFIG_HOSTS=127.0.0.1 ${RAILS} msip:stimulus_motores test:system
  } fi;
  if (test -f bin/pruebasjs) then {
    (CONFIG_HOSTS=127.0.0.1 ${RAILS} msip:stimulus_motores; bin/pruebasjs)
  } fi;
} fi;

echo "== Unificando resultados de pruebas en directorio clásico coverage"
mkdir -p coverage/
rm -rf coverage/{*,.*}
if (test "$RUTA_RELATIVA" = "/msip/") then {
  ${RAILS} app:msip:reporteregresion
} else {
  ${RAILS} msip:reporteregresion
} fi;

echo "== Copiando resultados para hacerlos visibles en el web en ruta cobertura"
# Copiar resultados para hacerlos visibles en web
mkdir -p $rutaap/public/${RUTA_RELATIVA}cobertura/
cp -rf coverage/* $rutaap/public/${RUTA_RELATIVA}cobertura/
cp -rf coverage/assets/* $rutaap/public/${RUTA_RELATIVA}assets/
