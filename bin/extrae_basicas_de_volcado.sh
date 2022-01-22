#!/bin/sh

volc=$1
if (test "$volc" = "" -o ! -f $volc) then {
  echo "Falta volcado como primer parámetro";
  exit 1;
} fi;

ord="grep "
for i in sip_etiqueta sip_tdocumento sivel2_gen_antecedente sivel2_gen_categoria \
  isivel2_gen_contexto sivel2_gen_contextovictima sivel2_gen_etnia \
  sivel2_gen_filiacion sivel2_gen_frontera sivel2_gen_iglesia \
  sivel2_gen_intervalo sivel2_gen_organizacion sivel2_gen_presponsable \
  sivel2_gen_profesion sivel2_gen_rangoedad sivel2_gen_region \
  sivel2_gen_resagresion sivel2_gen_sectorsocial sivel2_gen_supracategoria \
  sivel2_gen_tviolencia sivel2_gen_vinculoestado ; do
  ord="$ord -e \"INSERT INTO public.$i \""
done

ord="$ord $volc"
eval "$ord" | sort -u 


