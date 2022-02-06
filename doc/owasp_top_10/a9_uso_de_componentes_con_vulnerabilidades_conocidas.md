# Medidas para operar con componentes actualizados

* Se verifican archivos para dejar los necesarios.
* En github se tiene habilitado dependabot que alerta cuando hay
  gemas o paquetes npm desactualizados y con fallas de seguridad. 
  Cuando dependabot reporta una falla se resuelve.
* Semanalmente o con más frecuencia se actualizan tanto gemas como 
  paquetes. Ver commits con descripción "Actualiza" en
  * Repositorio de [sivel2 rama sivel2.0](https://github.com/pasosdeJesus/sivel2/commits/sivel2.0) 
    y sus motores 
  * [sivel2_gen rama sivel2.0](https://github.com/pasosdeJesus/sivel2_gen/commits/sivel2.0)
  * [heb412_gen rama v2.0](https://github.com/pasosdeJesus/heb412_gen/commits/v2.0)
  * [mr519_gen rama v2.0](https://github.com/pasosdeJesus/mr519_gen/commits/v2.0)
  * y [sip rama v2.0](https://github.com/pasosdeJesus/sip/commits/v2.0)
* Cada 6 meses se actualiza pila de software precedido de pruebas
  extensivas: sistema operativo, base de datos, lenguaje, marcos de trabajo.
  Ver desarrollo de esa pila en <https://github.com/pasosdeJesus/adJ>
* Ante cambios es la pila que afectan la aplicación, se planea ruta de
  actualización y se documenta bien en incidentes o bien en los motores
  (lo más tipico es en sip en <https://github.com/pasosdeJesus/sip/wiki>)
* Las gemas y paquetes npm se prefieren de repositorios oficiales 
  rubygems y npm.
* En ocasiones se ha requerido contribuir mejoras a componentes de terceros
  desactualizados o con problemas.  Como solo se emplean componentes de 
  fuentes abiertas, esto se ha hecho de manera pública en github.com o en
  el repositorio y canales públicos del software al que se contribuye.
  Cuando ha sido indispensable se ha bifurcado un repositorio público de
  un tercero (también de manera pública) para implementar un cambio que 
  requerimos  y que no ha sido aceptado por quienes mantiene (e.g
  https://github.com/pasosdeJesus/adJ y https://github.com/vtamara/cocoon ).

