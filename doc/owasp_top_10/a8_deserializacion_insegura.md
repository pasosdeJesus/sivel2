# Medidas para asegurar serialización segura

* En general no se hace serialización al lado del servidor. La exportación 
  de información se hace empleando un XML con DTD diseñado para esto sin
  serialización/deserialización.
  Las bitácoras incluyen los parametros recibidos escapados y limitando
  el tamaño.
* Al lado del cliente en algunos casos se hace de manera estándar para
  enviar datos a formularios pero la información enviada se verifica con 
  los controladores estándar.
