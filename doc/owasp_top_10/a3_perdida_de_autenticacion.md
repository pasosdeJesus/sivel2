* Se recomienda que sistematizar casos que hayan aparecido en medios 
  públicos o que provenga directamente de víctimas que hayan dado 
  su concentimiento para la publicación (preferiblemente por escrito). 
  De esta manera los datos sensibles son: Nombre y login de usuarios del sistema y fuentes de información. 
* Se recomienda usar seudónimos en las cuentas de usuario.  No se almacenan contraseñas sino condensados bcrypt.  
* Para cifrar las fuentes, se dan facilidades en adJ para crear partición cifrada bien con vnconfig o bien con RAID cifrado
  que usan bcrypt. 
* Para sitios de producción se dan instrucciones para desplegarlos con TLS de manera que toda
  transmisión sea cifada.  También se proveen instrucciones únicamente para desplegar
  en el mismo servidor el servidor web nginx y la aplicación rails con `unicorn`. Aunque
  nginx y unicorn no se comunican de forma cifrada, al estar en el mismo servidor 
  para lograr ver el tráfico plano un atacante tendría que tener privilegios de superusuario en el servidor.
• Verifique la efectividad de sus configuraciones y parámetros de forma independiente.
