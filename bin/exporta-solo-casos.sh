#!/bin/sh
# Saca copia de datos de casos de interes en instancias de SIVeL-Pro
# vtamara@pasosdeJesus.org. Dominio público. 2021

. .env

rlocal=/var/www/resbase/sivel2/bd/
base=$BD_DES
dm=`date +%d`

echo "Por generar sólo datos de casos para enviar a "\
  "$SIVEL2_EXP_USUARIO@$SIVEL2_EXP_MAQ:$SIVEL2_EXP_DIR "\
  "con opciones '$SIVEL2_EXP_OPSCP'";
echo "El usuario puede cambiarse en .env";
echo "[ENTER] para continuar o [Ctrl]-[C] para detener";
read a
echo "1 de 3. Copia ..."

cat > /tmp/incluir <<EOF
msip_perfilorgsocial
msip_sectororgsocial
msip_trelacion
msip_tsitio
sivel2_gen_antecedente
sivel2_gen_intervalo
sivel2_gen_actividadoficio
sivel2_gen_contexto
sivel2_gen_tviolencia
sivel2_gen_supracategoria
sivel2_gen_categoria
sivel2_gen_etnia
sivel2_gen_filiacion
sivel2_gen_iglesia
sivel2_gen_organizacion
sivel2_gen_presponsable
sivel2_gen_profesion
sivel2_gen_rangoedad
sivel2_gen_frontera
sivel2_gen_region
sivel2_gen_resagresion
sivel2_gen_sectorsocial
sivel2_gen_vinculoestado
sivel2_gen_escolaridad
sivel2_gen_estadocivil
sivel2_gen_maternidad
sivel2_gen_contextovictima
msip_orgsocial
msip_grupoper
msip_persona
sivel2_gen_caso
msip_orgsocial_persona
msip_orgsocial_sectororgsocial
msip_persona_trelacion
msip_ubicacion
sivel2_gen_victima
sivel2_gen_victimacolectiva
sivel2_gen_acto
sivel2_gen_actocolectivo
sivel2_gen_antecedente_caso
sivel2_gen_combatiente
sivel2_gen_antecedente_combatiente
sivel2_gen_antecedente_victima
sivel2_gen_antecedente_victimacolectiva
sivel2_gen_caso_presponsable
sivel2_gen_caso_categoria_presponsable
sivel2_gen_caso_contexto
sivel2_gen_caso_frontera
sivel2_gen_caso_region
sivel2_gen_caso_respuestafor
sivel2_gen_contextovictima_victima
sivel2_gen_filiacion_victimacolectiva
sivel2_gen_organizacion_victimacolectiva
sivel2_gen_profesion_victimacolectiva
sivel2_gen_rangoedad_victimacolectiva
sivel2_gen_sectorsocial_victimacolectiva
sivel2_gen_victimacolectiva_vinculoestado
EOF

ord="pg_dump $base --data-only -h /var/www/var/run/postgresql -U $BD_USUARIO --column-inserts"
for i in `cat /tmp/incluir`; do
	ord="$ord --table=$i"
done
echo $ord
eval $ord > $rlocal/sivelpro-$dm.sql


echo "2 de 3 . Transformando..."
#grep -a -v -f bin/actweb.grep $rlocal/sivel2_pro-$dm.sql | sed -e "s/\(.*INTO.*caso_usuario.*(\)[0-9]*,/\11,/g" > $rlocal/web-sf-sinf-$dm.sql
gzip $rlocal/sivelpro-$dm.sql

echo "3 de 3. Transfiriendo ..."
cmd="scp $SIVEL2_EXP_OPSCP $rlocal/sivelpro-$dm.sql.gz $SIVEL2_EXP_USUARIO@$SIVEL2_EXP_MAQ:$SIVEL2_EXP_DIR"
echo $cmd;
eval $cmd;

if (test "$?" = "0") then {
        echo "Ahora ingrese al servidor $SIVEL2_EXP_MAQ y ejecute desde el directorio del sitio:"
        echo " $ RAILS_ENV=production bin/rails msip:vuelca";
        echo " $ bin/borra-excepto-usuarios-bitacora-y-etiquetas.sh";
} fi;

