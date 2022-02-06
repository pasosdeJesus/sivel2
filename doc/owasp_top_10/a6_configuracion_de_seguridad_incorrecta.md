# Medidas para asegurar una configuración de seguridad correcta

* Somos desarrolladores de la pila de software en la distribución adJ de
  OpenBSD, que actualizamos, probamos y auditamos parcialmente cada 6 meses.
* La distribución adJ incluye SIVeL 2 como porte para automatizar más
  su instalación y configuración.
* Para minimizar esfuerzo de asegurar entornos de desarrollo, prueba y 
  producción se centraliza la configuración en un archivo `.env`. Esto
  asegura que los 3 entornos se configuran de la misma forma.
* Se han implementado pruebas de control de acceso bastante completas
  a partir del listado de rutas de la aplicación, ver
  <https://github.com/pasosdeJesus/sivel2_gen/issues/534>
* La aplicación tiene una arquitectura segmentada sin acceso de o a terceros.
* Se envían cabeceras seguras con un Content Security Policy ajustado.
  Ver
  [config/initializers/content_security_policy](https://github.com/pasosdeJesus/sivel2/blob/sivel2.0/config/initializers/content_security_policy.rb) ).
