Llamado público a auditar SIVeL 2.0

Gracias a Dios podemos ofrecer USD$50 por la primera falla
de seguridad encontrada y solucionada en SIVeL 2.0.x.

Si pertenece a una organización donde se documentan
infracciones al Derecho Internacional Humanitario o
violaciones a los Derechos Humanos con SIVeL  2, l@ invitamos a
hacer donaciones para este llamado público de forma que la
retribución aumente. 

Si es desarrollador(a) o interesad@ en seguridad informática
l@ invitamos a buscar fallas de seguridad en SIVeL 2, bien
experimentando en la instalación de prueba para este llamado,
o bien haciendo su propia instalación siguiendo las
recomendaciones para el ambiente de ejecución (ver
[README.md](https://github.com/pasosdeJesus/sivel2/blob/sivel2.0/README.md) )
o bien auditando las fuentes de dominio público escritas
en Ruby con marco de trabajo Ruby on Rails.

Para reportar la falla tenga en cuenta:
* Sumercé encontró la falla.
* La falla debe ser replicable en la instalación de prueba.
  Busque tanto en el formulario que no
  requiere autenticación:
  <https://defensor.info/sivel2/casos> ;
  como en otros componentes con el rol `analista` del usuario
  `operador` y clave `operador`: 
  <https://defensor.info/sivel2> ;
  o como administrador `sivel2` y clave `sivel2`.
  Esta instalación opera en la plataforma de ejecución
  recomendada (distribución [adJ](https://aprendiendo.pasosdeJesus.org)) 7.0
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
* Reporte la falla en 3 fases en orden: (1) envíe el reporte por correo a
  <seguridad@pasosdeJesus.org>, (2) abra una solicitud de cambio 
  (Pull Request) cedida al dominio público que solucione la falla
  pero sin dar indicaciones que se trata de una falla de seguridad
  ni como explotarla, (3) 10 días después por favor abra un reporte en el
  [Sistema de Seguimiento Público](https://github.com/pasosdeJesus/sivel2_gen/issues) 
  con un título que comience con "Falla de seguridad" y con
  su reporte.
* Su aporte será evaluado y respondido y  en caso de que podamos
  reproducir la falla y haya reportado como aquí se describe, le 
  entregaremos la retribución como lo prefiera: personalmente, 
  transferencia a cuenta Bancaria en Colombia o enviando a una billetera
  de criptomonedas.


Agradecemos su interés en esta convocatoria pública, cuya versión
más reciente está disponible en
<http://sivel.sf.net/1.2/llamado.html>
Le invitamos a distribuirla solidariamente y sin cambios.
