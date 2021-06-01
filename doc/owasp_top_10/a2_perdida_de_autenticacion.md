
# Prevenciones a perdida de autenticación

* Implementar autenticación multi-factor -estaremos evaluando
* Para poder configurar se despliega con unas credenciales por defecto de
  un usuario sivel2, pero la práctica es remplazarlo de inmediato
  por un usuario real de la aplicación.
* Controles contra contraseñas débiles --por hacer
* Políticas de longitude, complejidad y rotación --por hacer
* Se emplean mensajes genéricos iguales para operaciones para las que no hay
  autorización.
* Limitar o incrementar tiempo frente a intentos fallidos --por hacer
* Registrar en bitácora todo intente fallido --por hacer
* Alertar administradores ataques de fuerza bruta --por hacer

Al respecto: https://github.com/pasosdeJesus/sivel2_gen/issues/405
