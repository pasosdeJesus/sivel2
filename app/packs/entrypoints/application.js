/* eslint no-console:0 */

// Este archivo de compila automaticamente con Webpack, junto con otros
// archivos presentes en este directorio.  Lo animamos a poner la lógica
// de su aplicación en una estructura relevante en app/javascript y usar
// solo estos archivos pack para referenciar ese código de manera que sea
// compilado.
//
// Para referenciar este archivo agregue 
// <%= javascript_pack_tag 'application' %> 
// en el archivo de maquetación adecuado, como 
// app/views/layouts/application.html.erb


// Quite el comentario para copiar todas las imágenes estáticas de
// ../images en la carpeta de salida y referencielas con el auxiliar
// image_pack_tag en las vistas (e.g <%= image_pack_tag 'rails.png' %>)
// o con el siguiente auxiliar `imagePath`:
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

console.log('Hola Mundo desde Webpacker')

import Rails from "@rails/ujs"
Rails.start()

import Turbolinks from "turbolinks"
Turbolinks.start()

import $ from "expose-loader?exposes=$,jQuery!jquery";
import 'jquery-ui'
import 'jquery-ui/ui/widgets/autocomplete'
import 'jquery-ui/ui/focusable'
import 'jquery-ui/ui/data'
import 'jquery-ui/ui/widgets/tooltip'

import 'popper.js'              // Dialogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap'              // Maquetacion y elementos de diseño
import 'chosen-js/chosen.jquery';       // Cuadros de seleccion potenciados
import 'bootstrap-datepicker'
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js'

// Leaflet
var L = require('leaflet');
var mc= require('leaflet.markercluster');

document.addEventListener("DOMContentLoaded", function() {


});

