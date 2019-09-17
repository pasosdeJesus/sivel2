var map = null;
var marker= [];
var mc = null;
var markersClusterer= []
var bounds; 

map = L.map('map_osm',{ 
      center: [4.6682, -74.071], 
      zoom: 6
    }); 
L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors' }).addTo(map); 

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

 // bounds = new google.maps.LatLngBounds();

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
    markersClusterer.length = 0;
    mc.clearMarkers();
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
        markersClusterer.push(marker);
      }

    }
    $('#nrcasos').html('(<strong>' + numResult + '</strong> casos mostrados)');
    mc = L.markerClusterGroup();
    showAll()
    hideLoader();
  });
}


function createMarker(point, codigo, title) {

  var marker = new L.Marker(point);
  marker.on('click', onClick);
  marker.bindPopup(title);
  map.addLayer(marker);
  
  //bounds.extend(point);

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

      var descripcionCont = '<div class="infowindowcont"><div>' 
        + '<h3>' + titulo + '</h3>' + '</div>' + '<div>' + hechos + '</div></div>';

      var hechosCont = '<div class="infowindowcont"><table>';
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

      var victimasCont = '<div class="infowindowcont"><table>'
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
      victimasCont += '</td></tr></table>';
      var datosInfowindow= '<div id="infow">'
        +'<ul class="nav nav-tabs" id="myTab" role="tablist">'
        + '<li class="nav-item"><a class="nav-link active" id="infodes-tab" data-toggle="tab" href="#infodes" role="tab" aria-controls="infodes" aria-selected="true">Descripción</a></li>'
        +'<li class="nav-item"><a class="nav-link" id="infodatos-tab" data-toggle="tab" href="#infodatos" role="tab" aria-controls="infodatos" aria-selected="false">Datos</a></li>'
        +'<li class="nav-item"><a class="nav-link" id="infovictima-tab" data-toggle="tab" href="#infovictima" role="tab" aria-controls="infovictima" aria-selected="false">Víctimas</a></li>'
        +'</ul>'
        +'<div class="tab-content" id="myTabContent">'
        +'<div class="tab-pane fade show active" id="infodes" role="tabpanel" aria-labelledby="infodes-tab">'+ descripcionCont  +'</div>'
        +'<div class="tab-pane fade" id="infodatos" role="tabpanel" aria-labelledby="infodatos-tab">'+ hechosCont +'</div>'
        +'<div class="tab-pane fade" id="infovictima" role="tabpanel" aria-labelledby="infovctima-tab">'+ victimasCont +'</div>'
        +'</div>'
        +'</div>'

      var info = new google.maps.InfoWindow({
        content: datosInfowindow
      });
      info.open(map, marker);
      //cerrar infowindow cuando hagan clic fuera de él 
      $(document).on("click",function(e) {
        var container = $("#infow");
        if (!container.is(e.target) && container.has(e.target).length === 0) { 
          info.close();
        }
      });

      hideLoader();

    });
  }
  return marker;
}


