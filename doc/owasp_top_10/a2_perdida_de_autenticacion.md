
# Prevenciones a perdida de autenticación

* Se emplean mensajes genéricos iguales para operaciones para las que no hay
  autenticación
* Para poder desarrollar y configurar se inicia base de datos
  con unas credenciales por defecto de un usuario sivel2 y clave sivel2.
  Pero en aplicaciones de produccińo la práctica tras la primera 
  autenticación es remplazarlo por un usuario real de la aplicación con buena clave.
* Las cuentas se deshabilitan tras 3 intentos de ingreso fallido. Por esto nos
  parece innecesario "alertar administradores ataques de fuerza bruta".
* Está pendiente de hacerse:
  * Autenticación multi-factor
  * Controles contra contraseñas débiles. Al respecto: https://github.com/pasosdeJesus/sivel2_gen/issues/405
  * Políticas de longitud, complejidad y rotación.
  * Registrar en bitácora todo intente fallido.



