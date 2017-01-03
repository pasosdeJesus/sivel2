#!/bin/sh
# Hace pruebas, pruebas de regresión, envia a github y sube a heroku

if (test -f ".env") then {
	. ./.env
} fi;

grep "^ *gem *.sip.*, *path:" Gemfile > /dev/null 2> /dev/null
if (test "$?" = "0") then {
	echo "Gemfile incluye un sip cableado al sistema de archivos"
	exit 1;
} fi;
grep "^ *gem *.sivel2_gen.*, *path:" Gemfile > /dev/null 2> /dev/null
if (test "$?" = "0") then {
	echo "Gemfile incluye un sivel2_gen cableado al sistema de archivos"
	exit 1;
} fi;
grep "^ *gem *.debugger*" Gemfile > /dev/null 2> /dev/null
if (test "$?" = "0") then {
	echo "Gemfile incluye debugger que heroku no quiere"
	exit 1;
} fi;
#grep "^ *gem *.byebug*" Gemfile > /dev/null 2> /dev/null
#if (test "$?" = "0") then {
#	echo "Gemfile incluye byebug que rbx de travis-ci no quiere"
#	exit 1;
#} fi;

if (test "$SINAC" != "1") then {
  NOKOGIRI_USE_SYSTEM_LIBRARIES=1 MAKE=gmake make=gmake QMAKE=qmake4 bundle update
} fi;
if (test "$SININS" != "1") then {
	NOKOGIRI_USE_SYSTEM_LIBRARIES=1 MAKE=gmake make=gmake QMAKE=qmake4 bundle install
} fi;
if (test "$SINMIG" != "1") then {
	(bundle exec rake db:migrate sip:indices db:structure:dump)
	if (test "$?" != "0") then {
		exit 1;
	} fi;
} fi;

RAILS_ENV=test bundle exec rake db:drop db:setup db:migrate sip:indices
if (test "$?" != "0") then {
	echo "No puede preparse base de prueba";
	exit 1;
} fi;

bundle exec rails test
if (test "$?" != "0") then {
	echo "No pasaron pruebas";
	exit 1;
} fi;

RAILS_ENV=test bundle exec rake db:structure:dump
b=`git branch | grep "^*" | sed -e  "s/^* //g"`
git status -s
if (test "$MENSCONS" = "") then {
	MENSCONS="Actualiza"
} fi;
git commit -m "$MENSCONS" -a
git push origin ${b}
if (test "$?" != "0") then {
	echo "No pudo subirse el cambio a github";
	exit 1;
} fi;

if (test "$CONH" != "") then {
	git push heroku master
	heroku run rake db:migrate sip:indices
} fi;

