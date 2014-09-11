#!/bin/sh
# Hace prueba de regresión y envia a github

rspec
if (test "$?" = "0") then {
	b=`git branch | grep "^*" | sed -e  "s/^* //g"`
	git status -s
	git commit -a
	git push origin ${b}
} fi;

