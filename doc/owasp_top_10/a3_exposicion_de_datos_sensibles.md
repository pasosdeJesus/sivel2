# Prevenciones a exponer datos sensibles

* Se recomienda sistematizar casos que hayan aparecido en medios 
  públicos o que provenga directamente de víctimas que hayan dado 
  su consentimiento para la publicación (preferiblemente por escrito). 
  De esta manera los datos sensibles son: Nombre, login de usuarios del 
  sistema, correo del usuario y fuentes de información. 
* En la documentación se recomienda usar seudónimos en las cuentas de usuario
  y correos ficticios --entendiendo que no se recibirán correos de
  desbloquea en tal caso. No se almacenan contraseñas sino condensados bcrypt.  
* Para cifrar las fuentes, se dan facilidades en adJ para crear partición 
  cifrada bien con `vnconfig` o bien con RAID cifrado, ambos usan bcrypt. 
* Para sitios de producción se dan instrucciones para desplegarlos con TLS 
  de manera que toda transmisión sea cifada.  También se proveen instrucciones 
  únicamente para desplegar en el mismo servidor tanto `nginx` como la 
  aplicación rails con `unicorn`. Aunque `nginx` y `unicorn` no se comunican 
  de forma cifrada, al estar en el mismo servidor para lograr ver el tráfico 
  plano un atacante tendría que tener privilegios de superusuario en el 
  servidor.
* Especialmente para verificar esta parte se hará convocatoria pública a 
  auditar SIVeL2.
