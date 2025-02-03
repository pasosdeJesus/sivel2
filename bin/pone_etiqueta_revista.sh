#!/bin/sh

echo "Pone etiqueta de revista a casos de un periodo"
echo "Usar solo para último perido no para periodos históricos --que podrían
tener casos actualizados que no deben marcarse con la etiqueta de la revista"
fi="$1"
if (test "$fi" = "") then {
	echo "Falta fecha inical como primer parámetro" 
	exit 1;
} fi;
ff="$2"
if (test "$ff" = "") then {
	echo "Falta fecha final como segundo parámetro" 
	exit 1;
} fi;
idet="$3"
if (test "$idet" = "") then {
	echo "Falta id. de etiqueta de la revista como tercer parámetro" 
	exit 1;
} fi;
idus="$4"
if (test "$idus" = "") then {
	echo "Falta id. de usuario que pondrá la etiequeta como cuarto parámetro" 
	exit 1;
} fi;



. .env


echo "Etiquetas por agregar"
psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "SELECT
id AS id_caso, $idet AS id_etiqueta, $idus AS id_usuario, NOW() AS fecha,
NOW() AS created_at, now() AS updated_at FROM sivel2_gen_caso 
WHERE fecha>='2024-01-01' AND fecha<='2024-06-30';"
echo "Enter para agregarlas" 
read
psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "INSERT INTO
sivel2_gen_caso_etiqueta
(SELECT id AS id_caso, $idet AS id_etiqueta, $idus AS id_usuario, NOW() AS fecha,
NOW() AS created_at, now() AS updated_at FROM sivel2_gen_caso 
WHERE fecha>='2024-01-01' AND fecha<='2024-06-30');"

#psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "DELETE FROM sivel2_gen_caso WHERE fecha>='$f' AND TRIM(memo)='';"
