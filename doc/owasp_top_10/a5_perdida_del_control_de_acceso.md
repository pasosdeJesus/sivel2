* Para el control de acceso de utiliza la gema `cancancan` que centraliza las reglas en `app/models/ability.rb`
* Se han desarrollado pruebas de regresión con minitest específicas para probar el control de acceso de sivel2.  Ver en fuentes en directorio `test/controllers` las que comienzan con `control_acceso`
* Se ha revisado en la aplicación y en todos sus motores: 
  1. Que los controladores que están en `lib` no tengan `load_and_authorize_resource` (es responsabilidad de clases finales, no de modulos)
  2. Que los controladores que están en `app/controllers si tengan `load_and_authorize_resource` o cuando no aplique un comentario explicando
* En los motores y aplicaciones genéricas se especifica con brevedad el control de acceso llamando métodos
  de motores en la función `initialize` de `app/modles/ability.rb` (e.g `initialize_sip`, `initialize_mr519_gen`, 
  `initialize_heb412_gen` e `initialize_sivel2_gen`).  En aplicaciones finales se recomienda escribir completas las reglas
  en el archivo `app/models/ability.rb` para facilitar auditoria y evitar cambios inesperados al actualizar motores.
 
