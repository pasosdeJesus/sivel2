#!/bin/sh

echo "Pone etiqueta de revista a casos de un periodo"
echo "Usar solo para último periodo no para periodos históricos --que podrían
tener casos actualizados que no deben marcarse con la etiqueta de la revista"
fi="$1"
if (test "$fi" = "") then {
	echo "Falta fecha inicial como primer parámetro" 
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
	echo "Falta id. de usuario que pondrá la etiqueta como cuarto parámetro" 
	exit 1;
} fi;



. .env


echo "Etiquetas por agregar (en casos no-belicas a los que les faltan)"
cons="
SELECT id AS caso_id, 
  $idet AS etiqueta_id, 
  $idus AS usuario_id, 
  NOW() AS fecha,
  NOW() AS created_at, 
  NOW() AS updated_at 
FROM sivel2_gen_caso 
WHERE 
  fecha>='$fi' AND fecha<='$ff' AND 
  id NOT IN (
    SELECT caso_id 
    FROM sivel2_gen_caso_presponsable AS cp 
    WHERE cp.id IN (
      SELECT caso_presponsable_id 
      FROM sivel2_gen_caso_categoria_presponsable 
      WHERE categoria_id IN (
        SELECT cat.id 
        FROM sivel2_gen_categoria AS cat 
        JOIN sivel2_gen_supracategoria AS sup ON cat.supracategoria_id=sup.id 
        WHERE sup.tviolencia_id='C'
      )
    )
  ) AND 
  id NOT IN (
    SELECT caso_id 
    FROM sivel2_gen_caso_etiqueta
    WHERE etiqueta_id=$idet
  )
"
echo "Consulta base=$cons"

echo "Enter para ejecutarla" 
read
psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "$cons"

echo "Enter para agregarlas" 
read
psql -U $BD_USUARIO -h /var/www/var/run/postgresql $BD_PRO -c "INSERT INTO sivel2_gen_caso_etiqueta ($cons);"

