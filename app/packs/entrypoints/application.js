console.log('Hola Mundo desde Webpacker')

import Rails from "@rails/ujs"
Rails.start()
import { Turbo, cable } from "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"

var L = require('leaflet');
var mc= require('leaflet.markercluster');

import $ from "expose-loader?exposes=$,jQuery!jquery"
import 'popper.js'              // Diálogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap' // Maquetación y elementos de diseño
import 'chosen-js/chosen.jquery';      // Cuadros de selección potenciados
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
