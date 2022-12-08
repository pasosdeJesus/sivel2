* Se verifican archivos para dejar los necesarios.
* En github se tiene habilitado dependabot que alerta cuando hay
  gemas o paquetes npm desactualizados y con fallas de seguridad. 
  Cuando dependabot reporte una falla se resuelve.
* Semanalmente o con más frecuencia se actualizan tanto gemas como 
  paquetes. 
* Cada 6 meses se actualiza pila de software precedido de pruebas
  extensivas: sistema operativo, base de datos, lenguaje, marcos de trabajo.  
  Ante cambios es la pila que afectan la aplicación, se planea ruta de
  actualización y se documenta bien en incidentes o bien en los motores
  (lo más tipico es en msip en https://github.com/pasosdeJesus/msip/wiki)
* Las gemas y paquetes npm se obtiene de repositorios oficiales rubygems y npm.
* En ocasiones se ha requerido contribuir mejoras a componentes de terceros
  desactualizados o con problemas.  Como solo se emplean componentes de 
  fuentes abiertas, esto se ha hecho de manera pública en github.com o en
  el repositorio y canales públicos del software al que se contribuye.
  Cuando ha sido indispensable se ha bifurcado un repositorio público de
  un tercer (también de manera pública) para implementar un cambio que 
  requerimos  y que no ha sido aceptado por quienes mantiene (e.g
  https://github.com/pasosdeJesus/adJ y https://github.com/vtamara/cocoon ).

