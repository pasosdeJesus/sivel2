var map = null;
var marker= [];
var markers= null;
var bounds; 

  map = L.map('map_osm',{ 
    center: [4.6682, -74.071], 
    zoom: 6
  }); 

  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors' 
  }).addTo(map); 
  markers = L.markerClusterGroup();
   window.setTimeout(addCasesOsm, 0);
  // addCasesOsm();
//ícono de marker
//var iconoCaso = <%= asset_path('icon.png') %>

function showLoader() {
  $('#loader').show();
}

function hideLoader() {
  $('#loader').hide();
}

function downloadUrl(url, callback) {
  var request = window.ActiveXobject ?
    new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest;
  request.onreadystatechange = function() {
    if (request.readyState == 4) {
      callback(request);
    }
  };
  request.open('GET', url, true);
  request.send(null);
}


function addCasesOsm() {

  var desde = $('#inputDesde').val();
  var hasta = $('#inputHasta').val();
  var departamento = $('#departamento').val();
  var prresp = $('#presponsable').val();
  var tvio = $('#tvio').val();

  var root = window;
  sip_arregla_puntomontaje(root);
  var ruta = root.puntomontaje + 'casos.json';
  var requestUrl = ruta + '?utf8=' + '&filtro[fechaini]=' + desde + '&filtro[fechafin]=' + hasta;
  if (departamento != undefined && departamento != 0){
    requestUrl += '&filtro[departamento_id]=' + departamento;
  }
  if (prresp != undefined && prresp != 0){
    requestUrl += '&filtro[presponsable_id]=' + prresp;
  }
  if (tvio != undefined && tvio != 0){
    requestUrl += '&filtro[categoria_id]=' + tvio;
  }
  showLoader();
  downloadUrl(requestUrl, function(req) {
    data = req.responseText;
    if (data == null || data.substr(0, 1) != '{'){
      hideLoader();
      $('#nrcasos').html("0");
      window.alert("El URL" + requestUrl + "no retorno informacion JSON.\n\n" + data);
      return;
    }
    var o = jQuery.parseJSON(data);
    var numResult = 0;
    for(var codigo in o) {
      numResult++;
      var lat = o[codigo].latitud;
      var lng = o[codigo].longitud;
      var titulo= o[codigo].titulo;
      var fecha = o[codigo].fecha;

      if (lat != null || lng != null){
        var point= new L.LatLng(parseFloat(lat), parseFloat(lng));
        var title = fecha + ": " + titulo;
        createMarker(point, codigo, title);
      }
    }
    $('#nrcasos').html(numResult + ' Casos mostrados!');
    hideLoader();
  });
}

function createMarker(point, codigo, title) {

  var marker = new L.Marker(point);
  // Exportar los casos a formato GeoJson
  var geojson = marker.toGeoJSON();
 // console.log(geojson);

  //Acción al hacer clic en caso en el mapa
  marker.on('click', onClick);
  markers.addLayer(marker);
  map.addLayer(markers);
  
  function onClick() {
    showLoader();
    var root = window;
    sip_arregla_puntomontaje(root);
    var ruta = root.puntomontaje + 'casos/';
    var requestUrl = ruta + codigo + ".json";  
    downloadUrl(requestUrl, function(req) {
      data = req.responseText;

      //window.alert(data);
      if (data == null || data.substr(0, 1) != '{') {
        hideLoader();
        window.alert("El URL " + requestUrl +
          " no retorno detalles del caso\n " + data);
        return;
      }
      var o = jQuery.parseJSON(data);

      var id = o['caso'].id;
      var titulo = o['caso'].titulo; 
      var hechos = o['caso'].hechos; 
      var fecha = o['caso'].fecha; 
      var hora = o['caso'].hora; 
      var departamento = o['caso'].departamento; 
      var municipio = o['caso'].municipio; 
      var centro_poblado = o['caso'].centro_poblado;
      var victimas = o['caso'].victimas;
      var prresp = o['caso'].presponsables;

      var descripcionCont = '<div>' +
        '<h3>' + titulo + '</h3>' + '</div>' + '<div>' + hechos + '</div>';

      var hechosCont = '<div><table>';
      hechosCont += (fecha != "") ? '<tr><td>Fecha:</td><td>' +
        fecha + '</td></tr>' : '';
      hechosCont += (hora != "") ? '<tr><td>Hora:</td><td>' +
        hora + '</td></tr>' : '';
      hechosCont += (departamento != "") ? 
        '<tr><td>Departamento:</td><td>' +
        departamento + '</td></tr>' : '';
      hechosCont += (municipio != "") ? 
        '<tr><td>Municipio:</td><td>' +
        municipio + '</td></tr>' : '';
      hechosCont += (centro_poblado != "") ? 
        '<tr><td>Centro Poblado:</td><td>' +
        centro_poblado + '</td></tr>' : '';
      hechosCont += (codigo != "") ? 
        '<tr><td>Codigo:</td><td>' +
        codigo + '</td></tr>' : '';
      hechosCont += '</table></div>';

      var victimasCont = '<div><table>' +
        '<tr><td>Victimas:</td><td>';
      for(var cv in victimas) {
        var victima = victimas[cv];
        victimasCont += (victima != "") ? victima +
          '<br />' : 'SIN INFORMACIÓN';
      }

      victimasCont += '</td></tr><tr>' +
        '<td>Presuntos Responsables:</td><td>';
      for(var cp in prresp) {
        var prrespel = prresp[cp];
        victimasCont += (prrespel != "") ? prrespel +
          '<br />' : 'SIN INFORMACIÓN';
      }
      victimasCont += '</td></tr></table></div>';
      capa(descripcionCont, hechosCont, victimasCont);
      hideLoader();

    });
  }
  return marker;
}
// variable que guarda los detalles del marker al que se le dio click
var eventBackup;
// variable global donde se carga la capa flotante
var info;

// capa flotante donde se muestra la info al darle click sobre un maker
function capa(des, hec, vic){

  if (info != undefined) { // se valida si existe informacion en la capa, si es borra la capa
    info.remove(map); // esta linea quita la capa flotante
  }

  info = L.control();
  info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update(des, hec, vic);
    return this._div;
  };

  info.update = function (des, hec, vic) {
    this._div.innerHTML = '<button type="button" id="closeBtn" class="close" aria-label="Close">'+
         '<span aria-hidden="true">&times;</span>'+
         '</button><div id="infow">'+
        '<ul class="nav nav-tabs" id="myTab" role="tablist">'+
         '<li class="nav-item"><a class="nav-link active" id="infodes-tab" data-toggle="tab" href="#infodes" role="tab" aria-controls="infodes" aria-selected="true">Descripción</a></li>'+
        '<li class="nav-item"><a class="nav-link" id="infodatos-tab" data-toggle="tab" href="#infodatos" role="tab" aria-controls="infodatos" aria-selected="false">Datos</a></li>'+
        '<li class="nav-item"><a class="nav-link" id="infovictima-tab" data-toggle="tab" href="#infovictima" role="tab" aria-controls="infovictima" aria-selected="false">Víctimas</a></li>'+
        '</ul>'+
        '<div class="tab-content" id="myTabContent">'+
        '<div class="tab-pane fade show active" id="infodes" role="tabpanel" aria-labelledby="infodes-tab">'+ des +'</div>'+
        '<div class="tab-pane fade" id="infodatos" role="tabpanel" aria-labelledby="infodatos-tab">'+ hec +'</div>'+
        '<div class="tab-pane fade" id="infovictima" role="tabpanel" aria-labelledby="infovctima-tab">'+ vic +'</div>'+
        '</div>'+
        '</div>';
  };
  info.addTo(map);
  // Disable dragging when user's cursor enters the element
  info.getContainer().addEventListener('mouseover', function () {
    map.dragging.disable();
  });

  // Re-enable dragging when user's cursor leaves the element
  info.getContainer().addEventListener('mouseout', function () {
    map.dragging.enable();
  });
}

// Cierra la capa flotante desde el boton cerrar
$(document).on('click','#closeBtn', function(){
  info.remove(map);
});

// Cierra el info al hacer zoom in/out
map.on('zoom', function() {
  if (info != undefined) {
    info.remove(map);
  }
});

document.getElementById("addCasesOsm").addEventListener("click", function(){
 markers.clearLayers(); 
  addCasesOsm();
}, false);
