
# Medidas para evitar ataques de inyección de código

* En general estamos usando ActiveRecord como ORM para consultas SQL, el cual 
  escapa automáticamente.  En los casos que hemos construido consultas
  SQL directamente hemos empleado funciones para escapar como 
  `Sip::SqlHelper.escapar_param` y `Sivel2Gen::Caso.connection.quote_string(c)`
* En entradas de información por formularios Rails usamos lista
  blanca de parámetros como es práctica estándar en aplicaciones
  Rails. En filtros se usan sólo datos esperados y se
  escapan los que hacen parte de consultas.
* En llamadas a interprete de ordenes escapamos ordenes y argumentos
* Utilizamos `LIMIT` por ejemplo en las consultas que presentan datos, pues 
  estos van paginados.
* Como parte de la integración continua usamos el analizador estático de código 
  Rubocop en gitlab-ci.   Este generador es especialmente fuerte en detectar 
  inyecciones de código SQL y shell (con varios falsos positivos).
  A 5.Feb.2022 rubocop no encuentra falla alguna en sivel2 (rama sivel2.0) ni 
  en sus motores:

  | Motor/Aplicación | Enlace |
  |---|---|
  |`sip` rama `v2.0` | https://gitlab.com/pasosdeJesus/sip/-/jobs/2056728077 |
  | `mr519_gen` rama `v2.0`| https://gitlab.com/pasosdeJesus/mr519_gen/-/jobs/2056408460 |
  | `heb412_gen` rama `v2.0` | https://gitlab.com/pasosdeJesus/heb412_gen/-/jobs/2056469159 |
  | `sivel2_gen` rama `sivel2.0` | https://gitlab.com/pasosdeJesus/sivel2_gen/-/jobs/2056756448 |
  | `sivel2` rama `sivel2.0` | https://gitlab.com/pasosdeJesus/sivel2/-/jobs/2058146852 |

