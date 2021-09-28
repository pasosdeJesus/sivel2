console.log('Hola Mundo desde Webpacker')

import Rails from "@rails/ujs"
Rails.start()
import Turbolinks from "turbolinks"
Turbolinks.start()

import $ from "expose-loader?exposes=$,jQuery!jquery"

var L = require('leaflet');
var mc= require('leaflet.markercluster');

import 'popper.js'              // Dialogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap'              // Maquetacion y elementos de diseño
import 'chosen-js/chosen.jquery';       // Cuadros de seleccion potenciados
import 'bootstrap-datepicker'
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js'
import 'jquery-ui'
import 'jquery-ui/ui/widgets/autocomplete'
import 'jquery-ui/ui/focusable'
import 'jquery-ui/ui/data'

// Support component names relative to this directory:
/*var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext); */

import "controllers"
