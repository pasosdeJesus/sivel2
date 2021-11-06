# Prevención a entidades externas XML

* En la importación de casos desde archivos XML se valida que el DTD 
  sea sólo uno de los soportados y que el documento sea válido respecto al DTD.
* En importación de casos se desactiva importación de entidades desde 
  fuentes externas con `config.strict.noent` según recomienda
  <https://www.hacksplaining.com/prevention/xml-external-entities>
* Empleamos Nokogori para reconocer XML durante importación de casos y según 
  su documentación (ver https://nokogiri.org/tutorials/parsing_an_html_xml_document.html#encoding)
  "tratará la entrada como documentos no confiables por omisión, evitando así una clase de vulnerabilidades
  conocidas como procesamiento de 'Entidades externas XML'.  Lo que esto significa es que
  Nokogiri no intentará cargar DTDs externos ni acceder a la red en búsqueda de recursos
  externos."
 
