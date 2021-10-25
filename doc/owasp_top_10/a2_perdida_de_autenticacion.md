
# Prevenciones a perdida de autenticación

* Se emplean mensajes genéricos iguales para operaciones para las que no hay
  autorización.
* Las cuentas se deshabilitan tras 3 intentos de ingreso fallido.
* Para poder desarrollar y configurar las aplicaciones inician base de datos
  con unas credenciales por defecto de un usuario sivel2 y clave sivel2.
  Pero en aplicaciones de produccińo la práctica tras la primera 
  autenticación es remplazarlo por un usuario real de la aplicación con buena clave.
* Está pendiente de hacerse:
  * Autenticación multi-factor -estaremos evaluando
  * Controles contra contraseñas débiles. Al respecto: https://github.com/pasosdeJesus/sivel2_gen/issues/405
  * Políticas de longitude, complejidad y rotación.
  * Registrar en bitácora todo intente fallido.
  * Alertar administradores ataques de fuerza bruta.


