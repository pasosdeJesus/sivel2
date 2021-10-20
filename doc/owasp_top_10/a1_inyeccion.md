
# Prevención de ataques de inyección de código

* Estamos usando ActiveRecord como ORM para consultas SQL, el cual 
  escapa automáticamente.
* En entradas de información por formularios Rails usamos lista
  blanca de parámetros como es práctica estándar en aplicaciones
  Rails. En filtros se usan sólo datos esperados y se
  escapan los que hacen parte de consultas.
* En llamadas a interprete de ordenes escapamos ordenes y argumentos
* Utilizamos `LIMIT` por ejemplo en las consultas que presentan datos, pues 
  estos van paginados.
* Como parte de la integración continua usamos el analizador estático de código 
  Rubocop tanto con Hakiri como con gitlab-ci.  A la publicación de la versión
  2.0b17 todos están en verde (indicando que se antendieron todas las advertencias
  generadas por Rubocop):
  - [![sip](https://hakiri.io/github/pasosdeJesus/sip/master.svg)](https://hakiri.io/github/pasosdeJesus/sip/master)
  - [![mr519_gen](https://hakiri.io/github/pasosdeJesus/mr519_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/mr519_gen/master)
  - [![heb412_gen](https://hakiri.io/github/pasosdeJesus/heb412_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/heb412_gen/master)
  - [![sivel2_gen](https://hakiri.io/github/pasosdeJesus/sivel2_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2_gen/master)
  - [![sivel2](https://hakiri.io/github/pasosdeJesus/sivel2/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2/master)

