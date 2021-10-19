#!/bin/sh
# Genera volcado de todos los datos pero sin dueño y generando COPY para una
# restauración muy rápida.
# vtamara@pasosdeJesus.org. Dominio público. 2020

# Genera un script SQL que se ejecuta desde una base vacía para reconstruir
# pero con dueño diferente

. .env

dm=`date +%d`
echo "Por generar datos de casos para enviar a "\
  "$SIVEL2_EXP_USUARIO@$SIVEL2_EXP_MAQ:$SIVEL2_EXP_DIR "\
  "con opciones '$SIVEL2_EXP_OPSCP'";
echo "Esto puede cambiarse en .env";
echo "[ENTER] para continuar o [Ctrl]-[C] para detener";
read a
if (test "$RAILS_ENV" = "development") then {
  b=$BD_DES
} else {
  b=$BD_PRO
} fi;

function eval_con_eco {
  echo $@
  eval $@
}

echo "1 de 3. Genera volcado ..."
ord="pg_dump $b --no-owner --clean -h /var/www/var/run/postgresql -U $BD_USUARIO --no-owner"
eval_con_eco "pg_dump $b --no-owner --clean -h /var/www/var/run/postgresql -U
$BD_USUARIO --no-owner | grep -v 'DROP TABLE public.usuario;' | grep -v 'DROP SEQUENCE public.usuario_id_seq;' > $SIP_RUTA_VOLCADOS/sivel2-todo-$dm.sql"
#eval $ord > $SIP_RUTA_VOLCADOS/sivel2-todo-$dm.sql #Todo por procesar mas

echo "2 de 3. Comprime ..."
eval_con_eco "gzip $SIP_RUTA_VOLCADOS/sivel2-todo-$dm.sql"

if (test "$SIVEL2_EXP_USUARIO" != "") then {
  echo "3 de 3. Envía ..."
  if (test "$SIVEL2_EXP_MAQ" = "localhost" -o "$SIVEL2_EXP_MAQ" = "127.0.0.1") then {
    eval_con_eco "cp $SIP_RUTA_VOLCADOS/sivel2-todo-$dm.sql.gz $SIVEL2_EXP_DIR "
  } else {
    eval_con_eco "scp $SIVEL2_EXP_OPSCP $SIP_RUTA_VOLCADOS/sivel2-todo-$dm.sql.gz $SIVEL2_EXP_USUARIO@$SIVEL2_EXP_MAQ:$SIVEL2_EXP_DIR "
  } fi;
} fi;

echo "Restaurar en otra base y limpiar"

