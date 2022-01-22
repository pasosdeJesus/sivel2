#!/bin/sh

sal=$1
if (test "$sal" = "") then {
  echo "Falta primer parámetro como archivo de salida"
  exit 1;
} fi;

echo "" > $sal

if (test ! -f .env) then {
  echo "No existe .env";
  exit 1;
} fi;
. .env

for i in sip_etiqueta sip_tdocumento sivel2_gen_antecedente sivel2_gen_categoria \
  sivel2_gen_contexto sivel2_gen_contextovictima sivel2_gen_etnia \
  sivel2_gen_filiacion sivel2_gen_frontera sivel2_gen_iglesia \
  sivel2_gen_intervalo sivel2_gen_organizacion sivel2_gen_presponsable \
  sivel2_gen_profesion sivel2_gen_rangoedad sivel2_gen_region \
  sivel2_gen_resagresion sivel2_gen_sectorsocial sivel2_gen_supracategoria \
  sivel2_gen_tviolencia sivel2_gen_vinculoestado ; do
  cmd="psql --csv -h /var/www/var/run/postgresql -U $BD_USUARIO $BD_PRO -c \"SELECT id, nombre FROM $i ORDER BY id\" >> $sal"
eval $cmd
done


