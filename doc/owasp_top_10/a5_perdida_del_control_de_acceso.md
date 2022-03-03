# Medidas para evitar violaciones al control de acceso

* Para el control de acceso de utiliza la gema `cancancan` que centraliza las reglas en `app/models/ability.rb`
* Se ha documentado el control de acceso en detalle junto con la documentación del API, ver <https://github.com/pasosdeJesus/sivel2/blob/main/doc/API_sivel2.md>
* Se han desarrollado pruebas de regresión con minitest específicas para probar el control de acceso de sivel2.  Ver en fuentes en directorio `test/controllers` las que comienzan con `control_acceso`.  En total 1037 pruebas que se ejecutan en integración continúa de gitlab con cada cambio a fuentes, ver por ejemplo: https://github.com/pasosdeJesus/sivel2/blob/sivel2.0/config/initializers/content_security_policy.rb
* Se ha revisado en la aplicación y en todos sus motores: 
  1. Que los controladores que están en `lib` no tengan `load_and_authorize_resource` (es responsabilidad de clases finales, no de modulos)
  2. Que los controladores que están en `app/controllers` si tengan `load_and_authorize_resource` o cuando no aplique un comentario explicando
* Aplicamos [convención de sip para control de acceso en aplicaciones y motores](https://github.com/pasosdeJesus/sip/blob/main/doc/convenciones.md#control-de-acceso).
 
