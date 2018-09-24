#!/bin/sh
# Actualiza de github


if (test -f ".env") then {
	. .env
} fi;
if (test "$RC" = "") then {
	export RC=sivel2;
} fi;
bin/detiene.sh
if (test "$?" != "0") then { 
	echo "Problema al detener"; 
	exit 1; 
} fi;
git pull
if (test "$?" != "0") then { 
	echo "Problema con git pull"; 
	exit 1; 
} fi;
bundle install
if (test "$?" != "0") then { 
	echo "Problema con bundle install"; 
	exit 1; 
} fi;
bundle exec rails db:migrate RAILS_ENV=production
if (test "$?" != "0") then { 
	echo "Problema con db:migrate"; 
	exit 1; 
} fi;
bin/corre.sh
if (test "$?" != "0") then { 
	echo "Problema al volver a iniciar"; 
	exit 1; 
} fi;


