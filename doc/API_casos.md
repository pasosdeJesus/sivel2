# Descripción de la ruta de casos empleada por el API de mapa, por exportaciones JSON y XML en SIVeL 2

En el momento de consultar datos acerca de casos, 
SIVeL 2 puede obtener dinámicamente tanto como las generalidades
básicas del caso como también el caso con todos los detalles del mismo. 
Estas dos formas de consultas son la base para mostrar
información y dependen de las rutas seleccionadas ya sea para 
consultar reportes de JSON,  XRLAT (XML) y parámetros seleccionados 
de filtro para la consulta de casos en búsqueda avanzada o  en el mapa. 

A continuación se presenta las diferentes rutas de consulta de casos
de acuerdo a lo anteriormente mencionado:

## Ruta 1. `Consulta de casos por filtro avanzado`
En el menú Casos -> Listado, además de los casos listados, 
está presente el botón de búsqueda avanzada, el cual abre un filtro 
para buscar casos especificando algunos parametros, una vez definidos 
los parámetros se pulsa el botón Filtrar y SIVeL 2 muestra los casos filtrados. Por ejemplo suponiendo que se hace una consulta sin especificar 
parametros de búsqueda en el filtro, la ruta generada es la siguiente:

```
casos.html?&filtro[departamento_id]=&filtro[inc_ubicaciones]=1&filtro[orden]=ubicacion&filtro[fechaini]=&filtro[fechafin]=&filtro[inc_fecha]=1&filtro[presponsable_id]=&filtro[inc_presponsables]=1&filtro[categoria_id]=&filtro[inc_tipificacion]=1&filtro[nombres]=&filtro[apellidos]=&filtro[inc_victimas]=1&filtro[sexo]=&filtro[rangoedad_id]=&filtro[descripcion]=&filtro[inc_memo]=1&filtro[conetiqueta1]=true&filtro[etiqueta1]=&filtro[conetiqueta2]=true&filtro[etiqueta2]=&filtro[usuario_id]=&filtro[fechaingini]=&filtro[fechaingfin]=&filtro[codigo]=&filtro[inc_casoid]=1&filtro[paginar]=0&filtro[paginar]=1&filtro[disgenera]=reprevista.html&idplantilla=reprevista&commit=Enviar
```

Los parametros de la forma filtro[inc_x] indican si debe o no retornarse una información, esto se logra especificando 1 en el filtro desado, e.g filtro[inc_ubicaciones]=1 indica que si deben retornarse las ubicaciones, estos parámtetros son: inc_ubicaciones, inc_fecha, inc_presponsable, inc_tipifacion, inc_victimas, inc_memo, inc_casoid. 

También es posible ordenar los casos según algún parámetro, por ejemplo al especificar filtro[orden]=ubicacion los casos se ordenaran según su ubicación.

A continuación se muestran ejemplos de cómo puede modificarse la ruta
a medida que se agregan paramateros al filtro:

Fecha de inicio es el 1 de Enero de 2018: 
`filtro[fechaini]=2018-01-01`

Fecha final es el 6 de Julio de 2019: 
`filtro[fechafin]=2019-07-06`

Departamento es Cauca:
`filtro[departamento_id]=17`

Municipio es Popayán:
`filtro[municipio_id]=46`

Centro Poblado es Puelenje:
`filtro[clase_id]=1959`

Presunto Responsable es Guerrila:
`filtro[presponsable_id]=25`

Tipificación es Tortura:
`filtro[categoria_id]=12`

Nombres de vícitma es Luis Alejandro:
`filtro[nombres]=Luis Alejandro`

Apellidos de víctima es Cruz Lopez:
`filtro[apellidos]=Cruz Lopez`

Sexo es masculino:
`filtro[sexo]=M`

Rango de edad es de los 16 a los 25 años:
`filtro[rangoedad_id]=2`

Descripción de los hechos es "Descripcion de ejemplo":
`filtro[descripcion]=Descripcion de ejemplo`

Los casos con códigos 6000 y 700:
`filtro[codigo]=6000+7000`


Los datos geográficos están disponibles en Internet (busque DIVIPOLA) 
o en SQL en las fuentes de SIVeL en el archivo datos-geo-col.sql.

Esta misma ruta es empleada por SIVeL 2 para los reportes de casos 
en JSON y XRLAT que se explicará en el siguiente ítem.

## Ruta 2. `Casos.json y Casos.xrlat`

El reporte de casos se puede obtener tanto en JSON como en XRLAT, 
a continuación se muestra cómo están definidas sus rutas
y los parámetros establecidos.

### XRLAT

Suponiendo que se quiere obtener un reporte de revista 
xml de todos los casos, basta con ir a la ruta 
http://181.143.184.115/sivel2/casos.xrlat y SIVeL 2 mostrará
el reporte completo siguiendo el docmuneto DTD ubicado en 
http://sincodh.pasosdejesus.org/relatos/relatos-097.dtd

La estructura definida para presentar este reporte es la siguiente:

```XML
<relatos>
  <relato>
    ...Información del caso
  </relato>
  <relato>
    ...Información del caso
  </relato>
</relatos>
```

### JSON 

Para mostrar un reporte JSON de varios casos, se ha optado por solo mostrar algunas generalidades o elementos básicos del caso como lo son:

latitud: decimal para sistema de proyección WGS84.

longitud: decimal para sistema de proyección WGS84.

titulo: Titulo del caso.

fecha: Fecha del caso.

Un ejemplo de ruta de exportación de los casos en reporte JSON es el siguiente:

```
/sivel2/casos.json?filtro[q]=&filtro[departamento_id]&filtro[inc_ubicaciones]=1&filtro[orden]=ubicacion&filtro[fechaini]=&filtro[fechafin]=&filtro[inc_fecha]=1&filtro[presponsable_id]=&filtro[inc_presponsables]=1&filtro[inc_tipificacion]=1&filtro[nombres]=&filtro[apellidos]=&filtro[inc_victimas]=1&filtro[sexo]=&filtro[rangoedad_id]=&filtro[sectorsocial_id]=&filtro[organizacion_id]=&filtro[profesion_id]=&filtro[descripcion]=&filtro[inc_memo]=1&filtro[conetiqueta1]=true&filtro[etiqueta1]=&filtro[conetiqueta2]=true&filtro[etiqueta2]=&filtro[usuario_id]=&filtro[fechaingini]=&filtro[fechaingfin]=&filtro[codigo]=&filtro[inc_casoid]=1&filtro[paginar]=0&filtro[paginar]=1&filtro[disgenera]=reprevista.json&idplantilla=reprevista
```
La respuesta del detalle será un objeto JSON como por ejemplo:

```JSON
"108":{
  "latitud":3.01349776470494,
  "longitud":-76.4865299568979,
  "titulo":"Tíulo de ejemplo 1",
  "hora":"4 pm"}
"110":{
  "latitud":3.01329233105802,
  "longitud":-76.4869831605996,
  "titulo":"Título de ejemplo 2",
  "hora":"6 pm"}
```

Se incluirá además el departamento y municipio de la ubicación principal si el parámetro `filtro[inc_ubicaciones]` es 2 y se incluirá la descripción del caso si `filtro[inc_memo]` es 2.

## Ruta 2. `Casos/1.json o Casos/1.xrlat`

Para conusltar un caso en detalle, SIVeL 2 proporciona vistas html, 
json y xrlat (xml). Las rutas de estas vistas se obtienen al agregar
la extensión correspondiente al final de http://181.143.184.115/sivel2/casos/id.[extensión]. 
Para el caso de la extensión JSON. SIVeL 2 
responde con los detalles del caso con un objeto JSON con una sola propiedad caso cuyo valor es un objeto con las propiedades:

id: Identificación
titulo
hechos: Descripción o memo del caso
fecha
hora
departamento: principal
municipio: principal
centro_poblado: principal
presponsables: un objeto que puede tener varios ítems, uno por presunto responsable, la propiedad de cada uno será la identificación del presunto responsable y su valor será el nombre
victimas: un objeto que puede tener varios ítems, uno por víctima individual del caso, la propiedad de cada uno será la identificación de la víctima y su valor será los nombres de la víctima seguido de un espacio y los apellidos.

A conitnuación se muestra un ejemplo de la respuesta JSON a una de estas peticiones:

```JSON
{"caso":
  {"id":129,
   "titulo":"aaa",
   "hechos":"En su informe anual sobre la situación de derechos humanos en Colombia, la Oficina del Alto Comisionado de la ONU para este tema, que actualmente está a cargo de la expresidenta chilena Michelle Bachelet, sostiene que en el 2018 el homicidio aumentó en el 49 por ciento de los municipios y llama la atención sobre la persistencia de los altos niveles de impunidad en este tema.",
   "fecha":"2019-08-05",
   "hora":"6  pm",
   "departamento":"CALDAS",
   "municipio":"PALESTINA",
   "centro_poblado":"CARTAGENA",
   "presponsables":
     [{"id":5,"nombre":"ARMADA"}],
   "victimas":[{"105":"aaa bbb"}]
  }
}
```

Para el caso de XRLAT sí se presenta un informe detallado
 del caso en formato xml y se descarga automáticamente en un archivo llamado [id].xrlat

## Conteo de Casos

Se ha construido también una ruta para poder obtener mediante un arreglo el número total de casos por fecha y por departamento. La ruta recibe los parámetros de fecha inicial y fecha final en que se quiere realizar la consulta y está definida de la siguiente forma:

```
sivel2/casos/cuenta?[fechaini]='2001-01-01'&[fechafin]='2020-06-30' 
```

La respuesta a esta petición del API son objetos de la siguiente forma:

```JSON
{
  fecha: "2001-01-01", 
  departamento: "CAUCA", 
  count: "45"
}
```
De esta forma vienen especificados lo objetos para todas las fechas dentro del rango y todos los departamentos. Es obligatorio especificar los parámetros de fecha inicial y fecha final, además si el caso no tiene ubicación, este entrará a sumar en el conteo de esa fecha con departamento nulo.
