// Archivo manifesto que será compila en application.js e incluirá todos los archivos que se listen
// a continuación.
//
// Cualquier archivo JavaScript/Coffee de este directorio, lib/assets/javascripts, vendor/assets/javascripts,
// o vendor/assets/javascripts de los pllugins, si los hay, pueden referenciarse aquí usando rutas relativas
//
// No se recomienda agregar código directamente aquí, pero si lo hace, aparecerá al final
// del archivo compilado.
//
// Lea el README de Sprockets (https://github.com/sstephenson/sprockets#sprockets-directives) para ver 
// de las directivas soportadas.
//
//= require best_in_place
//= require sip/motor
//= require heb412_gen/motor
//= require mr519_gen/motor
//= require sivel2_gen/motor
//= require sivel2_gen/mapaosm
//= require apo214/motor
//= require_tree .

document.addEventListener('turbolinks:load', function() {
  var root;
  root = typeof exports !== "undefined" && exports !== null ? 
    exports : window;
  sip_prepara_eventos_comunes(root, null, false);
  heb412_gen_prepara_eventos_comunes(root);
  mr519_gen_prepara_eventos_comunes(root);
  sivel2_gen_prepara_eventos_comunes(root);
  apo214_prepara_eventos_comunes(root);
  sivel2_gen_prepara_eventos_unicos(root);

  // Siguiente de https://github.com/turbolinks/turbolinks/issues/75
  // pero tampoco logra que permita pasar de una pestaña a otra
  // en ficha caso.  Seguimos con turbolinks 2.5.3
  //Turbolinks.Controller.prototype.nodeIsVisitableOld = 
  //	Turbolinks.Controller.prototype.nodeIsVisitable;

  //Turbolinks.Controller.prototype.nodeIsVisitable = function (elem) {
  //	var href = elem.getAttribute('href') || '';
  //	var anchor = false;
  //	if (href[0] === "#") {
  //	  anchor = document.querySelector(href);
  //	} 

  //	return !anchor && 
  //		Turbolinks.Controller.prototype.nodeIsVisitableOld(elem);
  //}; 
});

