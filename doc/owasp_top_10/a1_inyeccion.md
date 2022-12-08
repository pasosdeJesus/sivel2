
# Prevención de ataques de inyección de código

* En general estamos usando ActiveRecord como ORM para consultas SQL, el cual 
  escapa automáticamente.  En los casos que hemos construido consultas
  SQL directamente hemos empleado funciones para escapar como 
  `Modelo.connection.quote_string(c)`
* En entradas de información por formularios Rails usamos lista
  blanca de parámetros como es práctica estándar en aplicaciones
  Rails. En filtros se usan sólo datos esperados y se
  escapan los que hacen parte de consultas.
* En llamadas a interprete de ordenes escapamos ordenes y argumentos
* Utilizamos `LIMIT` por ejemplo en las consultas que presentan datos, pues 
  estos van paginados.
* Como parte de la integración continua usamos el analizador estático de código 
  Rubocop tanto con Hakiri como con gitlab-ci.   Consideramos que este 
  generador es especialmente fuerte en detectar inyecciones de código SQL y 
  al interprete de ordenes (con varios falsos positivos).
  El 19.Abr.2021, a la publicación de la versión 2.0b17 las banderas de todos 
  los motores y la aplicación están en verde (indicando que se antendieron 
  todas las advertencias generadas por Rubocop):
  ![image](https://user-images.githubusercontent.com/701221/138012276-c091f7b1-cd15-4b65-b4a0-662e4dbc92b6.png)
* En este momento el estado es:
  | Motor/Aplicación | Estado |
  |---|---|
  |`msip` | [![msip](https://hakiri.io/github/pasosdeJesus/msip/master.svg)](https://hakiri.io/github/pasosdeJesus/msip/master)  |
  | `mr519_gen` | [![mr519_gen](https://hakiri.io/github/pasosdeJesus/mr519_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/mr519_gen/master)  |
  | `heb412_gen` | [![heb412_gen](https://hakiri.io/github/pasosdeJesus/heb412_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/heb412_gen/master) |
  | `sivel2_gen` | [![sivel2_gen](https://hakiri.io/github/pasosdeJesus/sivel2_gen/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2_gen/master) |
  | `sivel2` | [![sivel2](https://hakiri.io/github/pasosdeJesus/sivel2/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2/master) |

