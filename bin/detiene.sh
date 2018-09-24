#!/bin/sh
# Inicia servicio

if (test -f ".env") then {
	. .env
} fi;
if (test "$RC" = "") then {
	RC=sivel2
} fi;
if (test ! -f /etc/rc.d/$RC) then {
	echo "Falta script /etc/rc.d/$RC"
	exit 1;
} fi;

doas sh /etc/rc.d/$RC -d stop

