#!/bin/sh
# Saca copia de datos de casos de interesa en instancias de 
# SIVeL-Pro
# vtamara@pasosdeJesus.org. Dominio público. 2020

# Genera un script SQL que se ejecuta desde una base vacia

. .env

rlocal=/var/www/resbase/sivel2/bd/
dm=`date +%d`
echo "Por generar datos de casos para enviar a  $usuarioact@$maquinaweb:$dirweb con opciones '$opscpweb'";
echo "El usuario puede cambiarse en .env";
echo "[ENTER] para continuar o [Ctrl]-[C] para detener";
read a
echo "1 de 3. Copia ..."

cat > /tmp/excluir <<EOF
usuario
mr519_gen_encuestausuario
msip_anexo
msip_bitacora
msip_fuenteprensa
msip_grupo
msip_grupo_usuario
msip_oficina
sivel2_gen_caso_etiqueta
sivel2_gen_caso_fotra
sivel2_gen_caso_fuenteprensa
sivel2_gen_caso_usuario
msip_etiqueta
sivel2_gen_caso_usuario
EOF

ord1="pg_dump $base --no-owner -h /var/www/var/run/postgresql -U $ubase --column-inserts"
ord2="pg_dump $base --no-owner --clean -h /var/www/var/run/postgresql -U $ubase --no-owner --schema-only"
for i in `cat /tmp/excluir`; do 
	ord1="$ord1 --exclude-table=$i"
done
echo $ord2
eval $ord2 > $rlocal/sivel-web-$dm.sql #Solo esquema de todo
echo $ord1
eval $ord1 >> $rlocal/sivel-web-$dm.sql # Datos de lo no excluido

echo "2 de 3 . Transformando..."
#grep -a -v -f bin/actweb.grep $rlocal/sivel2_pro-$dm.sql | sed -e "s/\(.*INTO.*caso_usuario.*(\)[0-9]*,/\11,/g" > $rlocal/web-sf-sinf-$dm.sql
gzip $rlocal/sivel-web-$dm.sql

echo "3 de 3. Transfiriendo ..."
cmd="scp $opscpweb $rlocal/sivel-web-$dm.sql.gz $usuarioact@$maquinaweb:$dirweb"
echo $cmd;
eval $cmd;

if (test "$?" = "0") then {
        echo "Ahora ingrese al servidor $maquinaweb y ejecute desde el directorio del sitio:"
        echo "  $ bin/borra-excepto-usuarios-bitacora-y-etiquetas.sh";
        echo "Y modifique fechas en conf.php";
	echo "Para eliminar bélicas desde $maquinaweb ejecute: ";
        echo "  $ ../../bin/elim-belicas.sh";
} fi;

