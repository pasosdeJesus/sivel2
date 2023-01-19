#!/bin/sh
# Actualiza dependencias, revisa errores comunes, 
# ejecuta pruebas y envía a repositorio

if (test -f ".env") then {
  rutaap="./"
} elif (test -f "test/dummy/.env") then {
  rutaap="test/dummy"
} else {
  echo "No se determino ruta de aplicación. Falta archivo .env"
  exit 1;
} fi;

echo "Ruta de la aplicación: $rutaap"

s=`grep -B 1 "^ *path" Gemfile 2> /dev/null`
if (test "$?" = "0") then {
  echo "Gemfile incluye gema cableada al sistema de archivos ($s)"
  exit 1;
} fi;

grep "^ *gem *.debugger*" Gemfile > /dev/null 2> /dev/null
if (test "$?" = "0") then {
  echo "Gemfile incluye debugger"
  exit 1;
} fi;
grep "^ *gem *.byebug*" Gemfile > /dev/null 2> /dev/null
if (test "$?" = "0") then {
  echo "Gemfile incluye byebug que rbx de travis-ci no quiere"
  exit 1;
} fi;

if (test "$SINAC" != "1") then {
  rer=`bundle config get path | grep ":" | head -n 1 | sed -e "s/.*\"\(.*\)\"/\1/g"`
  rubyver=`ruby -v | sed -e "s/^[^ ]* \([0-9].[0-9]\).*/\1/g"`
  rutapore="$rer/ruby/$rubyver/cache/bundler/git/"
  if (test -d "$rutapore") then {
    echo "Eliminando $rutapore/*"
    rm -rf $rutapore/*
  } fi;
  NOKOGIRI_USE_SYSTEM_LIBRARIES=1 MAKE=gmake make=gmake QMAKE=qmake4 bundle update
  NOKOGIRI_USE_SYSTEM_LIBRARIES=1 MAKE=gmake make=gmake QMAKE=qmake4 bundle update --bundler
  if (test "$?" != "0") then {
    exit 1;
  } fi;
  (cd $rutaap; CXX=c++ yarn upgrade)
  if (test "$?" != "0") then {
    exit 1;
  } fi;
} fi;

if (test "$SININS" != "1") then {
  NOKOGIRI_USE_SYSTEM_LIBRARIES=1 MAKE=gmake make=gmake QMAKE=qmake4 bundle install
  if (test "$?" != "0") then {
    exit 1;
  } fi;

  echo "\n== Enlaza controladores stimulus de motores =="
  (cd $rutaap; bin/rails msip:stimulus_motores)
  if (test "$?" != "0") then {
    exit 1;
  } fi;

  (cd $rutaap; CXX=c++ yarn install; bin/rails assets:precompile)
  if (test "$?" != "0") then {
    exit 1;
  } fi;
} fi;

if (test "$SINMIG" != "1") then {
  (cd $rutaap; bin/rails db:migrate msip:indices db:schema:dump)
  if (test "$?" != "0") then {
    exit 1;
  } fi;
} fi;

bin/regresion.sh


(cd $rutaap; RAILS_ENV=test bin/rails db:schema:dump)

b=`git branch | grep "^*" | sed -e  "s/^* //g"`
git status -s
if (test "$MENSCONS" = "") then {
  MENSCONS="Actualiza"
} fi;
git commit -m "$MENSCONS" -a
git push origin ${b}
if (test "$?" != "0") then {
  echo "No pudo subirse el cambio a gitlab";
  exit 1;
} fi;

