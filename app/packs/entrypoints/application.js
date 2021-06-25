/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

console.log('Hola Mundo desde Webpacker')

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
// import * as ActiveStorage from "@rails/activestorage"
// import "channels"

Rails.start()
//require('@rails/ujs').start()   // Javascript no intrusivo segun rails
Turbolinks.start()
//require('turbolinks').start()   // Acelera carga de paginas

//ActiveStorage.start()

var L = require('leaflet');
var mc= require('leaflet.markercluster');

import $ from "expose-loader?exposes=$,jQuery!jquery"
import 'popper.js'              // Dialogos emergentes usados por bootstrap
import 'bootstrap'              // Maquetacion y elementos de diseño
import 'chosen-js/chosen.jquery';       // Cuadros de seleccion potenciados
import 'bootstrap-datepicker'
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js'
import 'jquery-ui'
import 'jquery-ui/ui/widgets/autocomplete'
import 'jquery-ui/ui/focusable'
import 'jquery-ui/ui/data'

