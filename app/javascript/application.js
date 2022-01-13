/* eslint no-console:0 */

console.log('Hola Mundo desde Javascript modular')

import mrujs from "mrujs";
import "@hotwired/turbo-rails";
mrujs.start();

import './jquery'
import '../../vendedor/recursos/javascripts/jquery-ui.js'

import 'popper.js'              // Dialogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap'              // Maquetacion y elementos de diseño
import 'chosen-js/chosen.jquery';       // Cuadros de seleccion potenciados
import 'bootstrap-datepicker'
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js'

// Apexcharts
import ApexCharts from 'apexcharts'
window.ApexCharts = ApexCharts
import apexes from 'apexcharts/dist/locales/es.json'
Apex.chart = {
  locales: [apexes],
  defaultLocale: 'es',
}

import 'gridstack'

// Leaflet
var L = require('leaflet');
var mc= require('leaflet.markercluster');

import plotly_serietiempo_actos from './plotly_actos'

document.addEventListener("DOMContentLoaded", function() {

  var p = new URL(document.URL).pathname.split('/')
  var p2ult = ''
  if (p.length>2) { 
    p2ult = p[p.length - 2] + "/" + p[p.length - 1]
  }
  console.log("p2ult=" + p2ult)
  if (p2ult == 'graficar/actos_individuales') {
    plotly_serietiempo_actos() 
  }

});

