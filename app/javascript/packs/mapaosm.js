var map = null;
var marker= [];
var mc = null;
var bounds; 
map = L.map('map_osm',{ 
      center: [4.6682, -74.071], 
      zoom: 6
    }); 
L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors' }).addTo(map); 

var markers = L.markerClusterGroup();

window.setTimeout(addCases, 0);

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


function addCases(refresh) {

  var desde = $('#inputDesde').val();
  var hasta = $('#inputHasta').val();
  var departamento = $('#departamento').val();
  var prresp = $('#presponsable').val();
  var tvio = $('#tvio').val();

  var root = window
  sip_arregla_puntomontaje(root)
  var ruta = root.puntomontaje + 'casos.json'
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
  if (refresh == true) {
   // markersClusterer.length = 0;
   // mc.clearMarkers();
  };
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
        var marker = createMarker(point, codigo, title);
      }
    }
    $('#nrcasos').html('(<strong>' + numResult + '</strong> casos mostrados)');
    hideLoader();
  });
}


function createMarker(point, codigo, title) {

  var marker = new L.Marker(point);
  marker.on('click', onClick);
  markers.addLayer(marker);
  map.addLayer(markers);
  
  function onClick() {
    showLoader();
    var root = window
    sip_arregla_puntomontaje(root)
    var ruta = root.puntomontaje + 'casos/'
    var requestUrl = ruta + codigo + ".json";  
    downloadUrl(requestUrl, function(req) {
      data = req.responseText;

      //window.alert(data);
      if (data == null || data.substr(0, 1) != '{') {
        hideLoader();
        window.alert("El URL " + requestUrl 
          + " no retorno detalles del caso\n " + data);
        return;
      }
      var o = jQuery.parseJSON(data);

      var id = o["caso"].id;
      var titulo = o["caso"].titulo; 
      var hechos = o["caso"].hechos; 
      var fecha = o["caso"].fecha; 
      var hora = o["caso"].hora; 
      var departamento = o["caso"].departamento; 
      var municipio = o["caso"].municipio; 
      var centro_poblado = o["caso"].centro_poblado;
      var victimas = o["caso"].victimas;
      var prresp = o["caso"].presponsables;

      var descripcionCont = '<div>' 
        + '<h3>' + titulo + '</h3>' + '</div>' + '<div>' + hechos + '</div>';

      var hechosCont = '<div><table>';
      hechosCont += (fecha != "") ? '<tr><td>Fecha:</td><td>' 
        + fecha + '</td></tr>' : '';
      hechosCont += (hora != "") ? '<tr><td>Hora:</td><td>' 
        + hora + '</td></tr>' : '';
      hechosCont += (departamento != "") ? 
        '<tr><td>Departamento:</td><td>' 
        + departamento + '</td></tr>' : '';
      hechosCont += (municipio != "") ? 
        '<tr><td>Municipio:</td><td>' 
        + municipio + '</td></tr>' : '';
      hechosCont += (centro_poblado != "") ? 
        '<tr><td>Centro Poblado:</td><td>' 
        + centro_poblado + '</td></tr>' : '';
      hechosCont += (codigo != "") ? 
        '<tr><td>Codigo:</td><td>' 
        + codigo + '</td></tr>' : '';
      hechosCont += '</table></div>';

      var victimasCont = '<div><table>'
        + '<tr><td>Victimas:</td><td>';
      for(var cv in victimas) {
        var victima = victimas[cv];
        victimasCont += (victima != "") ? victima 
          + '<br />' : 'SIN INFORMACIÓN';
      }

      victimasCont += '</td></tr><tr>'
        + '<td>Presuntos Responsables:</td><td>';
      for(var cp in prresp) {
        var prrespel = prresp[cp];
        victimasCont += (prrespel != "") ? prrespel 
          + '<br />' : 'SIN INFORMACIÓN';
      }
      victimasCont += '</td></tr></table></div>';
 // marker.bindPopup(datosInfowindow);
      capa(descripcionCont, hechosCont, victimasCont)
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
    this.update();
    return this._div;
  };

  info.update = function () {
    this._div.innerHTML = '<p>'+ des + hec + vic + '</p>';
    //this._div.innerHTML = '<div class="modal" tabindex="-1" role="dialog">        <div class="modal-dialog" role="document">          <div class="modal-content">            <div class="modal-header">              <h5 class="modal-title">Modal title</h5>              <button type="button" class="close" data-dismiss="modal" aria-label="Close">                <span aria-hidden="true">&times;</span>              </button>            </div>            <div class="modal-body">              <p>Modal body text goes here.</p>            </div>            <div class="modal-footer">              <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>              <button type="button" class="btn btn-primary">Save changes</button>            </div>          </div>        </div>      </div>';
  };
  info.addTo(map);
}

