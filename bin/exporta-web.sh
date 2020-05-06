#!/bin/sh
# Saca copia de la base sin fuentes ni usuarios y la envía a la
# máquina destinada para publicación
# vtamara@pasosdeJesus.org. Dominio público. 2020

. .env
rlocal=/var/www/resbase/sivel2/bd/
dm=`date +%d`
echo "Por generar copia sin fuentes para enviar a  $usuarioact@$maquinaweb:$dirweb con opciones '$opscpweb'";
echo "El usuario puede cambiarse en .env";
echo "[ENTER] para continuar o [Ctrl]-[C] para detener";
read a

echo "1 de 3. Copia ..."

cat > /tmp/excluir <<EOF
usuario
mr519_gen_encuestausuario
sip_anexo
sip_bitacora
sip_fuenteprensa
sip_grupo
sip_grupo_usuario
sip_oficina
sivel2_gen_caso_etiqueta
sivel2_gen_caso_fotra
sivel2_gen_caso_fuenteprensa
sivel2_gen_caso_usuario
sip_etiqueta
sivel2_gen_caso_usuario
EOF

ord1="pg_dump sivel2_pro -h /var/www/var/run/postgresql -U sivel2 --column-inserts"
ord2="pg_dump sivel2_pro -h /var/www/var/run/postgresql -U sivel2 --no-owner --schema-only"
for i in `cat /tmp/excluir`; do 
	ord1="$ord1 --exclude-table=$i"
	ord2="$ord2 --table=$i"
done
echo $ord2
eval $ord2 > $rlocal/sivel-web-$dm.sql
echo $ord1
eval $ord1 >> $rlocal/sivel-web-$dm.sql

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

