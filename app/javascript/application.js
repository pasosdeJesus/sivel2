/* eslint no-console:0 */

console.log('Hola Mundo desde ESM')

import Rails from "@rails/ujs";
if (typeof window.Rails == 'undefined') {
  Rails.start();
  window.Rails = Rails
}
import {Turbo} from '@hotwired/turbo-rails';

import 'popper.js'              // Dialogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap'              // Maquetacion y elementos de diseño
window.bootstrap = bootstrap

import L from 'leaflet'
window.L = L
import 'leaflet.markercluster'

import Msip__Motor from "./controllers/msip/motor"
window.Msip__Motor = Msip__Motor
Msip__Motor.iniciar()
import Mr519Gen__Motor from "./controllers/mr519_gen/motor"
window.Mr519Gen__Motor = Mr519Gen__Motor
Mr519Gen__Motor.iniciar()
import Heb412Gen__Motor from "./controllers/heb412_gen/motor"
window.Heb412Gen__Motor = Heb412Gen__Motor
Heb412Gen__Motor.iniciar()
import Apo214__Motor from "./controllers/apo214/motor"
window.Apo214__Motor = Apo214__Motor
Apo214__Motor.iniciar()
import Sivel2Gen__Motor from "./controllers/sivel2_gen/motor"
window.Sivel2Gen__Motor = Sivel2Gen__Motor
Sivel2Gen__Motor.iniciar()

import TomSelect from 'tom-select';
window.TomSelect = TomSelect;
window.configuracionTomSelect = {
    create: false,
    diacritics: true, //no sensitivo a acentos
    sortField: {
          field: "text",
          direction: "asc"
        }
}

// Apexcharts
import ApexCharts from 'apexcharts'
window.ApexCharts = ApexCharts
import apexes from 'apexcharts/dist/locales/es.json'
Apex.chart = {
  locales: [apexes],
  defaultLocale: 'es',
}

import 'gridstack'

import plotly_serietiempo_actos from './plotly_actos'

import {AutocompletaAjaxExpreg} from '@pasosdejesus/autocompleta_ajax'
window.AutocompletaAjaxExpreg = AutocompletaAjaxExpreg

let esperarRecursosSprocketsYDocumento = function (resolver) {
  if (typeof window.puntoMontaje == 'undefined') {
    setTimeout(esperarRecursosSprocketsYDocumento, 100, resolver)
    return false
  }
  if (document.readyState !== 'complete') {
    setTimeout(esperarRecursosSprocketsYDocumento, 100, resolver)
    return false
  }
  resolver("Recursos manejados con sprockets cargados y documento presentado en navegador")
    return true
  }

let promesaRecursosSprocketsYDocumento = new Promise((resolver, rechazar) => {
  esperarRecursosSprocketsYDocumento(resolver)
})


promesaRecursosSprocketsYDocumento.then((mensaje) => {
  // Este se ejecuta cada vez que se carga una página que no está en 
  // cache y tipicamente después de que se ha cargado la página completa 
  // y los recursos
  console.log(mensaje)
  var window = window;

  Msip__Motor.ejecutarAlCargarDocumentoYRecursos()
  Mr519Gen__Motor.ejecutarAlCargarDocumentoYRecursos()
  Heb412Gen__Motor.ejecutarAlCargarDocumentoYRecursos()
  Apo214__Motor.ejecutarAlCargarDocumentoYRecursos()
  Sivel2Gen__Motor.ejecutarAlCargarDocumentoYRecursos()

  var p = new URL(document.URL).pathname.split('/')
  var p2ult = ''
  if (p.length>2) { 
    p2ult = p[p.length - 2] + "/" + p[p.length - 1]
  }
  console.log("p2ult=" + p2ult)
  if (p2ult == 'graficar/actos_individuales') {
    plotly_serietiempo_actos() 
  }


})

document.addEventListener('turbo:load', (e) => {
 /* Lo que debe ejecutarse cada vez que turbo cargue una página,
 * tener cuidado porque puede dispararse el evento turbo varias
 * veces consecutivas al cargar una página.
 */
  
  console.log('Escuchador turbo:load')

  Msip__Motor.ejecutarAlCargarPagina()
  Mr519Gen__Motor.ejecutarAlCargarPagina()
  Heb412Gen__Motor.ejecutarAlCargarPagina()
  Apo214__Motor.ejecutarAlCargarPagina()
  Sivel2Gen__Motor.ejecutarAlCargarPagina()

})

import "./controllers"
