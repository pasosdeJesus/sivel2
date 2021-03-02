// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
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

