
# Prevención de ataques de inyección de código

* Estamos usando ActiveRecord como ORM para consultas SQL
* En entradas de información por formularios Rails implementa lista
  blanca de parámetros. En filtros se usan sólo datos esperados y se
  escapan.
* Escapar caracteres en consultas dinamicas
	* Para interprete de ordenes es escapan ordenes y argumentos
* Utilizar LIMIT y otros controles SQL.  Está implementando en las
  consultas que presentan datos, pues estos van paginados.
* Estamos usando el analizador estático de código de Hakiri, que reporta
  inyecciones de código.  Este analizador se corre de manera automática
  con cada envió al repositorio en github.

