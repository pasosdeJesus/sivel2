* Empleamos Ruby on Rails como marco de trabajo que por diseño codifica el
  contenido para evitar XSS.
* Los casos en los que hemos evitado el escapado automático de Ruby on Rails
  con el método `html_safe` los hemos revisado uno a uno, encontrando
  y cerrando esta vulnerabilidad cuando ha sido necesario
  (ver <https://github.com/pasosdeJesus/sivel2_gen/issues/586>
  y <https://github.com/pasosdeJesus/sivel2_gen/issues/587>)


