#!/bin/sh

nus=$1
if (test "$nus" = "") then {
  echo "Primer parámetro debe ser nombre de usuario"
  exit 1;
} fi;

bin/railsp dbconsole > /tmp/rdes <<EOF
  SELECT * FROM usuario WHERE nusuario='$nus';
EOF

grep "1 row" /tmp/rdes > /dev/null 2>&1
if (test "$?" != "0") then {
  echo "No se encontró usuario $nus"
  exit 1;
} fi;
#cat /tmp/rdes
#echo -n "Nueva clave: ";
#stty -echo; read clave; stty echo

bin/railsp dbconsole > /tmp/rdes2 <<EOF
  UPDATE usuario SET
  encrypted_password='\$2a\$10\$k6/igWfOjl2ExXN4HfZyo.FbsQENMzg7mbZFUQ9jUTxSykgCqbUxm',
  failed_attempts=0,
  locked_at=NULL,
  unlock_token=NULL,
  reset_password_token=NULL,
  reset_password_sent_at=NULL
  WHERE nusuario='$nus';
EOF

echo "Se ha desbloquead el usuario y se le ha asignado la clave cambiameya"

