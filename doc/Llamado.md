# Llamado público a auditar SIVeL 2.0

Gracias a Dios podemos ofrecer USD$100 por la primera falla
de seguridad que encuentre y resuelva en la versión más reciente de
SIVeL 2.0.

Si pertenece a una organización donde se documentan
infracciones al Derecho Internacional Humanitario o
violaciones a los Derechos Humanos con SIVeL  2, l@ invitamos a
ofrecer aumento de la retribución, para que este llamado 
público resulte más interesante para auditores de
seguridad.

Si es desarrollador(a) o auditor(a) de seguridad informática
l@ invitamos a buscar fallas de seguridad en SIVeL 2, bien
experimentando en la instalación de prueba para este llamado,
o bien haciendo su propia instalación siguiendo las
recomendaciones para el ambiente de ejecución (ver
[README.md](https://github.com/pasosdeJesus/sivel2/blob/sivel2.0/README.md) )
o bien auditando las fuentes que son de código abierto y escritas
en Ruby con marco de trabajo Ruby on Rails.

Para reportar la falla tenga en cuenta:
* Sumercé encontró la falla.
* La falla debe ser replicable en la instalación de prueba.
  Busque tanto en el formulario que no
  requiere autenticación:
  <https://defensor.info/sivel2/casos> ;
  como en otros componentes con el rol analista del usuario
  `operador` con clave `operador`: 
  <https://defensor.info/sivel2> ;
  o como administrador `sivel2` con clave `sivel2`.
  Esta instalación opera en la plataforma de ejecución
  recomendada (distribución [adJ](https://aprendiendo.pasosdeJesus.org) 7.0
  de OpenBSD, servidor web nginx con SSL,
  PostgreSQL con autenticación y Ruby on Rails 6.1)
  y con algunos datos producidos por el 
  [Banco De Datos de Violencia Política, DH y DIH del CINEP](http://www.nocheyniebla.org).
* Su reporte debe incluir la metodología que empleó para encontrarla 
  y proponer una solución para las fuentes de la rama `sivel2.0`
  disponibles en el repositorio git 
  https://github.com/pasosdeJesus/sivel2/tree/sivel2.0
  (puede ver ejemplos de auditorías a la versión 1.2
   en <https://github.com/pasosdeJesus/SIVeL/tree/master/doc>)
* Reporte la falla y suministre la solución como se indica en 
  <https://github.com/pasosdeJesus/sivel2/blob/sivel2.0/SECURITY.md>
* Su aporte será evaluado y respondido y  en caso de que podamos
  reproducir la falla y haya seguido los lineamientos aquí descritos,
  le entregaremos la retribución como lo prefiera: personalmente, 
  transferencia a cuenta Bancaria en Colombia o enviando a una billetera
  de Bitcoin, Ethereum o Toncoin.

Agradecemos su interés en esta convocatoria pública, cuya versión
más reciente está disponible en
<https://github.com/pasosdeJesus/sivel2/blob/sivel2.0/doc/Llamado.md>

Le invitamos a distribuirla solidariamente y sin cambios.
