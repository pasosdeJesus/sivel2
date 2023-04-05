# API de SiVel2
Esta es la documentación oficial de la API de la aplicación siVel2. Aquí están descritas todas las posibles peticiones y consultas, los parámetros establecidos, respuestas posibles y controles de acceso definidos en la configuración. 
- Inspirado por documentación Swagger API en estilo y estructura: https://petstore.swagger.io/#/pet
------------------------------------------------------------------------------------------

## Gestionando casos 

<details>
 <summary><code>GET / casos</code></summary>

Un usuario puede consumir de la API tanto las generalidades básicas de un conjunto de casos, como también un caso con todos los detalles del mismo.  Esta API está siendo utilizada para el reporte de casos en la aplicación pero igualmente esta siendo consumida por servicios como mapas y reportes completos de informes en planillas. Se puede generar reportes en diferentes formatos: JSON, XRLAT (XML) y HTML..

##### Parámetros

> Filtro avanzado:

> | Parámetro    | Tipo y Accesos                   | Ejemplo	  | 
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `:departamento_id`         | Integer / CP / AUT      | Departamento es Cauca: `filtro[departamento_id]=17`
> | `:municipio_id`         |Integer  / CP / AUT      | Municipio es Popayán: `filtro[municipio_id]=46` 
> | `:clase_id`         |Integer / CP / AUT          | Centro Poblado es Puelenje: `filtro[clase_id]=1959`
> | `:fechaini`         |String / CP / AUT       | Fecha de inicio es el 1 de Enero de 2018: `filtro[fechaini]=2018-01-01`
> | `:fechafin`         |String / CP  / AUT      | Fecha final es el 6 de Julio de 2019: `filtro[fechafin]=2019-07-06`
> | `:categoria_id`         |Integer / CP / AUT       | Tipificación es Tortura: `filtro[categoria_id]=12`
> | `:nombres`         |String / CP / AUT        | Nombres de vícitma es Luis Alejandro:  `filtro[nombres]=Luis Alejandro`
> | `:apellidos`         |String / CP / AUT     | Apellidos de víctima es Cruz Lopez:  `filtro[apellidos]=Cruz Lopez`
> | `:sexo`         |String / CP / AUT      |Sexo es masculino: `filtro[sexo]=M`
> | `:rangoedad_id`         |Integer / CP       | Rango de edad es de los 16 a los 25 años: `filtro[rangoedad_id]=2`
> | `:descripcion`         |String / CP / AUT      | Descripción de los hechos es "Descripcion de ejemplo": `filtro[descripcion]=Descripcion de ejemplo`
> | `:sectorsocial_id`         |Integer / CP       | Sector social es campesino: `filtro[sectorsocial_id]=1`
> | `:codigo`         |Integer / CP / AUT      | Los casos con códigos 6000 y 7000: `filtro[codigo]=6000+7000`
> | `:presponsable_id`         |Integer / AUT     | Presunto Responsable es Guerrila: `filtro[presponsable_id]=25` 
> | `:victimacol`         | String / AUT     | Victima colectiva es Primera línea: `filtro[victimacol]=Primera línea`
> | `:rangoedad_id`         |Integer / AUT     | Rango edad es De 0 a 15 Años: `filtro[rangoedad_id]=1`  
> | `:organizacion_id`         |Integer / AUT     | Organización es Campesina: Años : `filtro[organizacion_id]=1`    
> | `:profesion_id`         |Integer / AUT     |Profesión es MÉDICO/A: `filtro[profesion_id]=3` 
> | `:usuario_id`         |Integer / AUT     |El usuario es Alejandro Cruz: `filtro[usuario_id]=3`      
> | `:fechaingini`         |String / AUT     |Casos creados en 2018-01-01 o después : `filtro[usuario_id]=2018-01-01`      
> | `:fechaingfin`         |String / AUT     |Casos creados en 2018-01-01 o antes : `filtro[usuario_id]=2018-01-01`   
> | `:contexto_id`         |Integer / AUT     |El contexto es Proceso judicial: `filtro[contexto_id]=106`   
> | `:contextovictima_id`         |Integer / AUT     |El contexto de víctima es Falso positivo: `filtro[contextovictima_id]=1`  
> | `:orientacionsexual`         |String / AUT     |La orientación sexual es Heterosexual: `filtro[contextovictima_id]=H`                                          
> | `:inc_casoid`         |Integer / AUT     |Incluir la identificación del caso en el reporte: `filtro[inc_casoid]=1`  
> | `:inc_fecha`         |Integer / CP / AUT     |Incluir la fecha del caso en el reporte: `filtro[inc_casoid]=1`  
> | `:inc_ubicaciones`         |Integer / CP / AUT     |Incluir las ubicaciones del caso: `filtro[inc_ubicaciones]=1`
> | `:inc_presponsables`         |Integer / CP / AUT     |Incluir los presuntos responsables del caso en el reporte: `filtro[inc_presponsables]=1`    
> | `:inc_tipificacion`         |Integer / CP / AUT     |Incluir la tipificación del caso en el reporte: `filtro[inc_tipificacion]=1`  
> | `:inc_victimas`         |Integer / CP / AUT     |Incluir las víctimas del caso en el reporte: `filtro[inc_victimas]=1`  
> | `:inc_victimacol`         |Integer / AUT     |Incluir las víctimas colectivas del caso en el reporte: `filtro[inc_victimacol]=1`  
> | `:inc_memo`         |Integer / CP / AUT     |Incluir la descripción del caso en el reporte: `filtro[inc_memo]=1`  
> | `:orden`         |Integer / CP / AUT     | los casos se ordenaran según su ubicación: `filtro[orden]=ubicacion` 
Los datos geográficos están disponibles en Internet (busque DIVIPOLA) o en SQL en las fuentes de SIVeL en el archivo datos-geo-col.sql.

Siglas de control de acceso: 
- CP: Consulta pública
- AUT: Usuario autenticado

Esta misma ruta es empleada por SIVeL 2 para los reportes de casos en JSON y XRLAT, lo cual también hay parámetro para especificarlo:
> Formato:
	formato_salida: [html, json, xml] 
	

##### Respuestas

> | código http    | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `application/html;charset=UTF-8` / `application/json;charset=UTF-8` `application/xml;charset=UTF-8`        | Página html / Objeto JSON / Reporte XML  
> | `400`         |Error        | (Bad Request) Los datos enviados son incorrectos o hay datos obligatorios no enviados
> | `401`         | Error        | (Unauthorized) No hay autorización para llamar al servicio
> | `404`         | Error`        | (NotFound) No se encontró información
> | `500`         | Error        | Error en servidor                                                   |

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nodos.pasosdejesus.org:2400/sivel2/casos.html?filtro[q]=&filtro[departamento_id]=17&filtro[municipio_id]=1152&filtro[clase_id]=&filtro[inc_ubicaciones]=0&filtro[inc_ubicaciones]=1&filtro[orden]=ubicacion&filtro[fechaini]=&filtro[fechafin]=&filtro[inc_fecha]=0&filtro[inc_fecha]=1&filtro[presponsable_id][]=&filtro[inc_presponsables]=0&filtro[inc_presponsables]=1&filtro[inc_tipificacion]=0&filtro[inc_tipificacion]=1&filtro[nombres]=&filtro[apellidos]=&filtro[inc_victimas]=0&filtro[inc_victimas]=1&filtro[sexo]=&filtro[orientacionsexual]=&filtro[rangoedad_id]=&filtro[sectorsocial_id]=&filtro[organizacion_id]=&filtro[profesion_id]=&filtro[victimacol]=&filtro[inc_victimacol]=0&filtro[inc_victimacol]=1&filtro[descripcion]=&filtro[inc_memo]=`application/html;charset=UTF-8` / `application/json;charset=UTF-8` `application/xml;charset=UTF-8``application/html;charset=UTF-8` / `application/json;charset=UTF-8` `application/xml;charset=UTF-8`0&filtro[inc_memo]=1&filtro[conetiqueta1]=true&filtro[etiqueta1]=&filtro[conetiqueta2]=true&filtro[etiqueta2]=&filtro[usuario_id]=&filtro[fechaingini]=&filtro[fechaingfin]=&filtro[codigo]=&filtro[inc_casoid]=0&filtro[inc_casoid]=1&filtro[paginar]=0&filtro[paginar]=1&filtro[disgenera]=reprevista.html&idplantilla=reprevista&formato=html&formatosalida=html&commit=Enviar
> ```
##### Ejemplos de respuestas
- HTML:

	[896](#)

	Enero 16/2001

	DEPARTAMENTO: CAUCA  
	MUNICIPIO: SANTANDER DE QUILICHAO

	Cuatro hombres fueron asesinados en la zona urbana y rural de este municipio, en el cual hay presencia paramilitar y guerrillera.

	  
	Presunto Responsable: SIN INFORMACIÓN  
	  
	VIOLENCIA POLÍTICO SOCIAL  
	Asesinato por Persecución Política  
	  
	ERICK ALFREDO POPO AMU  
	LUIS ALFONSO IBARRA OSPINA  
	MILTON CESAR RESTREPO CAMPO  
	NORBERTO BALANTA FIGUEROA  

	----------

	[1039](#)

	Febrero 01/2001

	DEPARTAMENTO: CAUCA  
	MUNICIPIO: SANTANDER DE QUILICHAO

	Paramilitares de las AUC que se transportaban en motocicletas, portando armas de largo y corto alcance ejecutaron de varios impactos de arma de fuego a cuatro personas. Las víctimas fueron sacadas por la fuerza de sus viviendas y ejecutadas en presencia de sus familiares.

	  
	Presunto Responsable: POLO ESTATAL - AUC  
	  
	VIOLACIONES A LOS DERECHOS HUMANOS  
	Ejecución Extrajudicial por Persecución Política  
	INFRACCIONES AL DIH  
	Homicidio Intencional De Persona Protegida por Personas  
	  
	RAMIRO SANDOVAL MINA - CAMPESINO  
	JOSE ELCIDES CARABALI SANDOVAL - CAMPESINO  
	ASNORALDO CARABALI SANDOVAL - CAMPESINO  
	CARLOS EDUARDO ORTIZ LUCUMI - CAMPESINO
	
- JSON
Para mostrar un reporte JSON de varios casos, se ha optado por solo mostrar algunas generalidades o elementos básicos del caso como lo son:

	- latitud: decimal para sistema de proyección WGS84.

	- longitud: decimal para sistema de proyección WGS84.

	- titulo: Título del caso.

	- fecha: Fecha del caso.
	
	```json
	{
		"896":{"latitud":"3.0133211225242484","longitud":"-76.48676928148937","fecha":"2001-01-16"},
		"1039":{"latitud":"3.0131201235660483","longitud":"-76.48710295521055","fecha":"2001-02-01"}
	}
	```
- XML (Xrlat)
SIVeL 2 mostrará el reporte completo siguiendo el docmuneto DTD ubicado en [http://sincodh.pasosdejesus.org/relatos/relatos-098.dtd](http://sincodh.pasosdejesus.org/relatos/relatos-098.dtd)
	```xml
	<relatos>
		<relato>
			Información del relato...
		</relato>
		<relato>
			Información del relato...
		</relato>
	</relatos>
	```
</details>

<details>
 <summary><code>GET /casos/ :id </code></summary>

##### Parámetro

> | nombre            |  tipo     | tipo de dato      | descripción                         |
> |-------------------|-----------|----------------|-------------------------------------|
> | `id` |  requerido | Integer   | El identificador específico del caso        |

Para conusltar un caso en detalle, SIVeL 2 proporciona los formatos html, json y xrlat (xml). Las rutas de estas vistas se obtienen al agregar la extensión correspondiente al final de  sivel2/casos/id.[extensión]. Para el caso de la extensión JSON. SIVeL 2 responde con los detalles del caso con un objeto JSON con una sola propiedad caso cuyo valor es un objeto con las propiedades:

id: Identificación, titulo: título del caso, hechos: Descripción o memo del caso, fecha, hora, departamento principal, municipio principal, centro_poblado principal, presponsables: un objeto que puede tener varios ítems, uno por presunto responsable, la propiedad de cada uno será la identificación del presunto responsable y su valor será el nombre víctimas: un objeto que puede tener varios ítems, uno por víctima individual del caso, la propiedad de cada uno será la identificación de la víctima y su valor será los nombres de la víctima seguido de un espacio y los apellidos.
##### Respuestas

> | código http   | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `application/html;charset=UTF-8` / `application/json;charset=UTF-8` `application/xml;charset=UTF-8`        | página html  / Objeto JSON / Reporte XML                                                    |
> | `400`         | `application/json`                | `{"code":"400","message":"Bad Request"}`                            |

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nodos.pasosdejesus.org:2400/sivel2/casos/896
> ```

##### Ejemplos de respuestas
- JSON
```json
{"caso":
  {"id":129,
   "titulo":"aaa",
   "hechos":"En su informe anual sobre la situación de derechos humanos en Colombia, la Oficina del Alto Comisionado de la ONU para este temcurl -X GETa, que actualmente está a cargo de la expresidenta chilena Michelle Bachelet, sostiene que en el 2018 el homicidio aumentó en el 49 por ciento de los municipios y llama la atención sobre la persistencia de los altos niveles de impunidad en este tema.",
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
- XML
Para el caso de XRLAT sí se presenta un informe detallado del caso en formato xml y se descarga automáticamente en un archivo llamado [id].xrlat
</details>

<details>
 <summary><code>GET / casos / cuenta</code></summary>
 
Trae conteo de casos en un intervalo de fechas. Ruta para poder obtener mediante un arreglo el número total de casos por fecha y por departamento.

##### Parámetros

> | nombre            |  tipo     | tipo de dato      | descripción                         |
> |-------------------|-----------|----------------|-------------------------------------|
> | `fechaini` |  Requerido | String   | Fecha inicial de la cuenta        |
> | `fechafin` |  Requerido | String   | Fecha final de la cuenta        |

##### Respuestas

> | código http   | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `text/json;charset=UTF-8`        | Objeto JSON                                                     |
> | `400`         | `application/json`                | `{"code":"400","message":"Bad Request"}`                            |

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nodos.pasosdejesus.org:2400/sivel2/casos/cuenta?[fechaini]='2001-01-01'&[fechafin]='2020-06-30'
> ```
##### Ejemplo de respuesta
```json
{
  fecha: "2001-01-01", 
  departamento: "CAUCA", 
  count: "45"
}
```
De esta forma vienen especificados lo objetos para todas las fechas dentro del rango y todos los departamentos. Es obligatorio especificar los parámetros de fecha inicial y fecha final, además si el caso no tiene ubicación, este entrará a sumar en el conteo de esa fecha con departamento nulo.
</details>

 <details>
 <summary><code>Resumen control de acceso de casos</code><code>(permisos)</code></summary>
 
 -  Consulta pública:
	 - Consultar hasta 2000 registros en la API (puede usar los filtros para disminuir el número de registros)
	 - Consultar un caso en formato HTML, JSON y XML
	 - Buscar casos con los parámetros limitados a la consulta pública
	 - Contar casos
 - Usuario autenticado
	 - Consulta listado de casos ilimitado
	 - Consultar un caso en formato HTML, JSON y XML
	 - Buscar casos con los parámetros para usuario autenticado
	 -  Contar casos
- Usuario autenticado como observador u operador sin grupo:
	- Refrescar casos
	- No puede crear un nuevo caso
	- Leer un caso
	- Cambiar etiquetas de un caso
- Usuario con grupo observador parte casos:
	- Mostrar y leer un caso 
- Usuario operador analista de casos:
	- Leer un caso
	- Crear un caso
	- Editar y actualizar un caso
	- Eliminar un caso
	- Refrescar un caso
- Usuario con rol administrador:
	- Todos los permisos de gestionar casos
</details>

<details>
 <summary><code>GET / casos / importarrelatos</code></summary>

Ruta utilizada para acceder a la vista de importación de relatos.

##### Ejemplo url
> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/casos/importarrelatos"
> ```

##### Ejemplo de respuestas
La respuesta es una página HTML con un formulario que te permite seleccionar el archivo de relatos que desea importar

##### Control de Acceso
Únicamente pueden importar relatos usuarios autenticados con rol administrador. 
 </details>

<details>
 <summary><code>GET / casos / mapaosm </code></summary>

Ruta utilizada para acceder a la vista del mapa de casos de Open Street Map.
##### Parámetros 
fechaini: String, fecafin: String, departamento_id: integer, categoria_id: integer, presponsable_id: integer

##### Ejemplo url
> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/casos/mapaosm"
> ```

##### Ejemplo de respuestas
La respuesta es una página HTML con un mapa que te permite visualizar los casos a través de marcadores con la longitud y latitud de la ubicación principal del caso. 

##### Control de Acceso
Cualquier usuario autenticado puede acceder a casos mapaosm.  
 </details>

<details>
 <summary><code>GET / casofotras / nuevo</code></summary>

Ruta utilizada para crear un registro de sivel2_gen_casofotra para el caso que recibe por parámetro caso_id. Pone valores simples en los casos requeridos.

##### Parámetros 
caso_id: integer
##### Ejemplo url
> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/casofotras/nuevo?caso_id=1365"
> ```

##### Ejemplo de respuestas
Las respuestas pueden ser en JS, JSON y HTML y retornan el identificador del nuevo registro de casofotra creado

##### Control de Acceso
Únicamente pueden eliminar actos colectivos usuarios autenticados con rol administrador y con rol operador perteneciente a grupo analista de casos.
 </details>

<details>
 <summary><code>GET / casos / refresca</code></summary>

Ruta utilizada para refrescar el listado de casos existentes.

##### Ejemplo url
> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/casos/refresca"
> ```

##### Ejemplo de respuestas
La respuesta es una página HTML y con el mensaje de éxito "Listado de Casos refrescado" con fecha y hora de la acción.

##### Control de Acceso
Únicamente pueden refrescar el listado de casos los usuarios autenticados con rol administrador y con rol operador perteneciente a grupo analista de casos.
 </details>

<details>
 <summary><code>GET / casos / lista</code></summary>

Ruta utilizada para listar ubicaciones según parámetro de tabla que puede ser departamento, municipio o clase.

##### Ejemplo url
> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/casos/lista?tabla="departamento"&pais_id=170
> ```

##### Ejemplo de respuestas
La respuesta es una página HTML y con el listado de ubicaciones según los parámetros establecidos.

##### Control de Acceso
Únicamente pueden refrescar el listar, usuarios autenticados con rol administrador y con rol operador perteneciente a grupo analista de casos.
 </details>

## Actos 
<details>
 <summary><code>PATCH / actos / agregar</code></summary>

Ruta utilizada para agregar actos dentro de la creación de un caso, actualmente no puede ser utilizada externamente del formulario de casos, sin embargo están establecidos permisos específicos para hacer uso del método.

##### Parámetros 
Sivel2Gen::Acto(presponsable_id: integer, categoria_id: integer, persona_id: integer, caso_id: integer, created_at: datetime, updated_at: datetime, id: integer)
##### Control de Acceso
Únicamente pueden crear actos usuarios autenticados con rol administrador y con rol operador perteneciente a grupo analista de casos.

 </details>
<details>
 <summary><code> GET / actos / eliminar</code></summary>

Ruta utilizada para eliminar actos dentro de la creación de un caso, actualmente no puede ser utilizada externamente del formulario de casos, sin embargo están establecidos permisos específicos para hacer uso del método.

##### Parámetros 
id_acto: integer
##### Control de Acceso
Únicamente pueden eliminar actos usuarios autenticados con rol administrador y con rol operador perteneciente a grupo analista de casos.
</details>
 
<details>
 <summary><code>PATCH / actoscolectivos / agregar</code></summary>

Ruta utilizada para agregar actos colectivos dentro de la creación de un caso, actualmente no puede ser utilizada externamente del formulario de casos, sin embargo están establecidos permisos específicos para hacer uso del método.

##### Parámetros 
Sivel2Gen::Actocolectivo(presponsable_id: integer, categoria_id: integer, grupoper_id: integer, caso_id: integer, created_at: datetime, updated_at: datetime, id: integer)

##### Control de Acceso
Únicamente pueden crear actos colectivos usuarios autenticados con rol administrador y con rol operador perteneciente a grupo analista de casos.

 </details>
<details>
 <summary><code>GET / actoscolectivos / eliminar</code></summary>

Ruta utilizada para eliminar actos colectivos dentro de la creación de un caso, actualmente no puede ser utilizada externamente del formulario de casos, sin embargo están establecidos permisos específicos para hacer uso del método.

##### Parámetros 
id_actocolectivo: integer

##### Control de Acceso
Únicamente pueden eliminar actos colectivos usuarios autenticados con rol administrador y con rol operador perteneciente a grupo analista de casos.

</details>


------------------------------------------------------------------------------------------
## Listando víctimas 

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>victimas</code></summary>

##### Parámetros

> Filtro avanzado:

> | Parámetro    | Tipo y Accesos                   | Ejemplo	  | 
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `:buscaso_id`         | Integer / CP / AUT      | Víctimas en caso 154: `filtro[buscaso_id]=154`
> | `:busfecha_caso_localizadaini`         |String  / AUT      |Fecha de inicio es el 1 de Enero:  `filtro[busfecha_caso_localizadaini]=2018-01-01`
> | `:busfecha_caso_localizadafin`         |String  / AUT      |Fecha de fin es el 31 de Enero:  `filtro[busfecha_caso_localizadafin]=2018-01-31`
> | `:busubicacion_caso`         |String / AUT       | Ubicación de caso de víctima es Caldas: `filtro[busubicacion_caso]=CALDAS`
> | `:busnombre`         |String / AUT        | Nombres de vícitma es Luis Alejandro:  `filtro[busnombre]=Luis Alejandro`
> | `:buspconsolidado_x`         |String / CP / AUT     | Incluir categoría de violencia x:  `filtro[buspconsolidado_x]=Si`
El último parámetros se remplaza x por un número cualqueira de identificación de la tabla siel2_gen_pconsolidado, pudiendo así filtrar según las opciones: Si, No y Todos

Siglas de control de acceso: 
- AUT: Usuario autenticado

La respuesta a esta petición es un reporte html de casos por víctima, donde aparece la información en las columnas: Id caso, Fecha, Ubicación, Víctima, Cada categoría de violencia, nombres de presuntos responsables del caso, ids de presuntos responsables caso 
	

##### Respuestas

> | código http    | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `application/html;charset=UTF-8` / `application/json;charset=UTF-8` `application/xml;charset=UTF-8`        | Página html / Objeto JSON / Reporte XML  
> | `400`         |Error        | (Bad Request) Los datos enviados son incorrectos o hay datos obligatorios no enviados
> | `401`         | Error        | (Unauthorized) No hay autorización para llamar al servicio
> | `404`         | Error`        | (NotFound) No se encontró información
> | `500`         | Error        | Error en servidor                                                   |

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/victimas?filtro[buscaso_id]=&filtro[busfecha_caso_localizadaini]=&filtro[busfecha_caso_localizadafin]=&filtro[busubicacion_caso]=&filtro[busnombre]=Juan&filtro[buspconsolidado_1]=Si&filtro[buspconsolidado_2]=Todos&filtro[buspconsolidado_3]=Todos&filtro[buspconsolidado_4]=Todos&filtro[buspconsolidado_5]=Todos&filtro[buspconsolidado_6]=Todos&filtro[buspconsolidado_7]=Todos&filtro[buspconsolidado_8]=Todos&filtro[buspconsolidado_9]=Todos&filtro[buspconsolidado_10]=Todos&filtro[buspconsolidado_11]=Todos&filtro[buspconsolidado_12]=Todos&filtro[buspconsolidado_13]=Todos&filtro[buspconsolidado_14]=Todos&filtro[buspconsolidado_15]=Todos&filtro[buspconsolidado_16]=Todos&filtro[buspconsolidado_17]=Todos&filtro[buspconsolidado_18]=Todos&filtro[buspconsolidado_19]=Todos&filtro[buspconsolidado_20]=Todos&filtro[buspconsolidado_21]=Todos&filtro[buspconsolidado_22]=Todos&filtro[buspconsolidado_23]=Todos&filtro[buspconsolidado_24]=Todos&filtro[buspconsolidado_25]=Todos&filtro[buspconsolidado_26]=Todos&filtro[buspconsolidado_27]=Todos&filtro[buspconsolidado_28]=Todos&filtro[buspconsolidado_29]=Todos&filtro[buspconsolidado_30]=Todos&filtro[buspconsolidado_31]=Todos&filtro[buspconsolidado_32]=Todos&filtro[buspconsolidado_129]=Todos&filtro[buspconsolidado_130]=Todos&filtro[buspconsolidado_131]=Todos&filtrar=Filtrar&filtro[disgenera]=
> ```
##### Ejemplos de respuestas
- HTML:

	![enter image description here](https://github.com/alejocruzrcc/sivel2/blob/img-victimas/doc/imagenes/victimashtml.png)
	
	
- JSON
Para mostrar un reporte JSON de varias víctimas, se ha optado por solo mostrar algunas generalidades o elementos básicos de la víctima como lo son:

	- persona_id: identificador de la persona, tabla msip_persona a la que pertenece la víctima.

	- caso_id: identificador del caso al cual pertenece la víctima.

	- hijos: número de hijos de la víctima.

	- profesion_id: identificación de la tabla sivel2_gen_profesion de la profesión que tiene la vćitima.
	- rangoedad_id: identificación de la tabla sivel2_gen_rangoedad a la cual pertenece el rango de edad de la víctima
	- filiacion_id: identificación de la filiación política de la víctima.
	- sectorsocial_id: identificación del sector social de la víctima
	- organizacion_id: identificiación de la organización a la cual pertenece la víctima
	- vinculoestado_id: identificación del vínculo con el estado que tiene la víctima
	- organizacionarmada: Organización armada a la que pertenece la víctima
	- anotaciones: anotaciones sobre la víctima
	- etnia_id: identificación de la etnia de la víctima
	- iglesia_id: identificación de la iglesia de la víctima
	- orientacionsexual: Orientación sexual de la víctima
	
	```json
	[{"persona_id":326,"caso_id":932,"hijos":null,"profesion_id":22,"rangoedad_id":4,"filiacion_id":10,"sectorsocial_id":15,"organizacion_id":16,"vinculoestado_id":38,"organizacionarmada":35,"anotaciones":"","etnia_id":1,"iglesia_id":1,"orientacionsexual":"S","created_at":"2020-07-23T16:10:57.041-05:00","updated_at":"2020-07-23T16:11:28.060-05:00","id":246}]
	```
</details>

<details>
 <summary><code>Resumen control de acceso de víctimas</code><code>(permisos)</code></summary>
 
 -  Consulta pública:
	 - No es posible consultar información de víctimas en la consulta pública
 - Usuario autenticado observador o sin grupo:
	 - Consulta listado de víctimas formato HTML, y JSON 
	 - Buscar víctimas con los parámetros del filtro
- Usuario operador analista de casos:
	- Listar víctimas
	- Buscar víctimas por filtro
	- Crear víctimas
	- Editar y actualizar víctimas en casos
	- Eliminar víctimas en caso
- Usuario con rol administrador:
	- Todos los permisos de gestionar las víctimas
</details>
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>personas</code></summary>

##### Parámetros

> Filtro avanzado:

> | Parámetro    | Tipo y Accesos                   | Ejemplo	  | 
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `:busid`         | Integer / AUT      | Persona con id 145: `filtro[busid]=145`
> | `:busnombres`         |String  / AUT      |Nombre de persona es Alejandro:  `filtro[busnombres]=Alejandro`
> | `:busapellidos`         |String  / AUT      |Apellido de persona es Cruz  `filtro[busapellidos]=Cruz`
> | `:bussexo`         |String / AUT       | Sexo de persona es masculino: `filtro[bussexo]=M`
> | `:busnumerodocumento`         |String / AUT        |Número de documento de persona es 123456789:  `filtro[busnumerodocumento]=123456789`

Siglas de control de acceso: 
- AUT: Usuario autenticado

La respuesta a esta petición es un reporte HTML y JSON de las personas con los parámetros. 
	

##### Respuestas

> | código http    | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `application/html;charset=UTF-8` / `application/json;charset=UTF-8` `application/xml;charset=UTF-8`        | Página html / Objeto JSON / Reporte XML  
> | `400`         |Error        | (Bad Request) Los datos enviados son incorrectos o hay datos obligatorios no enviados
> | `401`         | Error        | (Unauthorized) No hay autorización para llamar al servicio
> | `404`         | Error`        | (NotFound) No se encontró información
> | `500`         | Error        | Error en servidor                                                   |

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/personas?filtro[busid]=&filtro[busnombres]=Alejandro&filtro[busapellidos]=Cruz&filtro[bussexo]=S&filtro[busnumerodocumento]=123456789&filtrar=Filtrar
> ```
##### Ejemplos de respuestas
- JSON
Para mostrar un reporte JSON de varias víctimas, se ha optado por solo mostrar algunas generalidades o elementos básicos de la víctima como lo son:

	- id: identificador de la persona.
	- nombres: nombres de la persona.
	- apellidos: apellidos de la persona.
	- anionac: Año de nacimiento
	- mesnac: Mes de nacimiento
	- dianac: Día de nacimiento
	- numerodocumento: Número de documento
	- pais_id: Identificación del país de nacimiento
	- departamento_id: Identificación del departamento de nacimiento
	- municipio_id: Identificación del municipio de nacimiento
	- clase_id: Identificación del centro poblado de nacimiento
	
	```json
	[{"id":253110,"nombres":"Alejo","apellidos":"Cruz","anionac":1998,"mesnac":3,"dianac":5,"sexo":"S","numerodocumento":"104524","created_at":"2021-06-22T10:09:25.262-05:00","updated_at":"2021-06-22T10:09:25.262-05:00","pais_id":170,"nacionalde":null,"tdocumento_id":1,"departamento_id":null,"municipio_id":null,"clase_id":null}]
	```
</details>


<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>personas</code><code><b>/</b></code> <code>datos</code></summary>
 
 Esta API permite traer datos de una persona organizado en un objeto JSON con los valores de id, nombres, apellidos, tipo de documento, numero de documento, sexo y fecha de nacimiento. Además si está autocompletando una persona de orgsocial persona agrega los campos de cargo y correo correspondiente.
 
##### Parámetros
Esta api recibe dos parámetros, uno obligatorio persona_id que es la identificación de la persona en la tabla msip_persona y otro parámetro opcional ac_orgsocial_persona con algún valor, cuando la persona hace parte de alguna organización social.  

El único formato de respuesta establecido es Json. 
##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/personas/datos.json?persona_id=253262&ac_orgsocial_persona=1
> ```

##### Ejemplos de respuestas
```json
	{"id":253262,"nombres":"Luis Alejandro","apellidos":"Cruz Ordoñez","sexo":"M","tdocumento":"CC","numerodocumento": "1061769227","dianac": 16,"mesnac": 04,"anionac": 1994}
```
##### Control de acceso 
Para consumir esta API se manejan los mismo permisos establecidos para /personas
</details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>personas</code><code><b>/</b></code> <code>remplazar</code></summary>
 
 Esta API permite remplazar personas en la tabla víctimas de caso. Más especificamente verifica y si la persona asociada a la victima corresponde con  una persona dada, si ya existe se obtiene un mensaje "Ya existe esa persona en el caso" y sino se hace el remplazo correspondiente guardando los valores de la víctima. 
 
##### Parámetros
Esta api recibe dos parámetros requeridos obligatorios: d_persona que es la identificación de la persona en la tabla msip_persona y otro parámetro opcional ac_orgsocial_persona con algún valor, cuando la persona hace parte de alguna organización social.  

El único formato de respuesta establecido es Json. 
##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/personas/remplazar?persona_id=94531&victima_id=98690```

##### Ejemplos de respuestas
Mensaje de ya existencia, o No layout correspondiente cuando se hace el remplazo 
##### Control de acceso 
Para esta ruta se manejan los mismo permisos establecidos para /personas
</details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>conteos/personas</code><code></code></summary>

Trae conteo demográfico de víctimas
Se ha construido también una ruta para poder obtener el número total de víctimas (personas individuales) en un intervalo de fechas con filtros especializados y de desagregación.
Los parámetros de del filtro iniciales son las fechas tal como se especifica a continuación:
##### Parámetros

> | nombre            |  tipo     | tipo de dato      | descripción                         |
> |-------------------|-----------|----------------|-------------------------------------|
> | `fechaini` |  Requerido | String   | Fecha inicial de la cuenta        |
> | `fechafin` |  Requerido | String   | Fecha final de la cuenta        |

Adicionalmente hay 10 criterios diferentes por los cuales es posible desagregar el conteo. Este se especifica en el parámetro "segun" por ejemplo:
> ```javascript
>  filtro[segun]=AÑO DE NACIMIENTO
>   ```
##### Parámetros desagregación (segun)

> | nombre            |  tipo     | tipo de dato      | descripción                         |
> |-------------------|-----------|----------------|-------------------------------------|
> | `AÑO DE NACIMIENTO` |  Requerido | String   | Año de nacimiento de la persona      |
> | `ETNIA` |  Requerido | String   | Etnia de la tabla víctima        |
> | `FILIACIÓN` |  Requerido | String   | Filiación política de la víctima|
> | `MES CASO` |  Requerido | String   | Mes del caso|
> | `ORGANIZACIÓN` |  Requerido | String   | Organización a la que pertenece la víctima|
> | `PROFESIÓN` |  Requerido | String   | Profesión de la víctima|
> | `RANGO DE EDAD` |  Requerido | String   | Rango de edad de la víctima|
> | `SECTOR SOCIAL` |  Requerido | String   | Sector social de la víctima|
> | `SEXO` |  Requerido | String   | Sexo de la persona |
> | `VINCULO CON EL ESTADO` |  Requerido | String   | Vínculo con el estado|

Además de dos filtros especializados por los cuales de puede expandir el conteo: Departamento y Municipio. Lugares geográficas de nacimiento de las víctimas asociadas mediante las tablas msip_departamento y msip_municipio respectivamente. El parámetro es booleano y se representa de la siguiente forma: 
> ```javascript
> filtro[departamento]=1
> ```
> ```javascript
> filtro[municipio]=1
> ```

##### Respuestas

> | código http   | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `text/html;charset=UTF-8`        | Status: ok. Página html                           |
> | `400`         | `application/html`                |  Bad Request   |

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/conteos/personas?filtro[fechaini]=01/Ene/2000&filtro[fechafin]=31/Ene/2021&filtro[segun]=VÍNCULO CON EL ESTADO&filtro[departamento]=1&filtro[municipio]=0&commit=Contar
> ```
##### Ejemplo de respuesta
La respuesta es una tabla html en donde la primera columna es el criterio de desagregación, la segunda y tercera el filtro de geolocalización (departamento y/o municipio) y la última el número de las víctimas por fila. 
![enter image description here](https://github.com/alejocruzrcc/sivel2/blob/img-victimas/doc/imagenes/conteo_personas.png)

##### Control de acceso
Actualmente, cualquier usuario autenticado con cualquiera de los tres roles (Administrador, Directivo y Operador), puede realizar el conteo demográfico de las víctimas. Un usuario desde la consulta web pública o sin autenticarse no puede realizar el conteo. 
 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>gruposper</code></summary>

Para consumir los grupos de personas existentes en la aplicación, esta dispuesta esta ruta. Esta trae registros asociados al modelo Msip::Grupoper.
La estructura de los datos está dada por un objetos con dos propiedades: value, que es el nombre del grupo de personas e id, que es la identificación del grupo de personas. 

##### Parámetros
Es necesario fijar un parámetro en la ruta denominado "term",  que es usado también en autocompletación. Este es un string que va a buscar los grupos de personas que en su nombre contengan este valor.

El único formato de respuesta establecido es Json. 

##### Control de Acceso
Cualquier persona autenticada puede acceder a este recurso.
No disponible para consulta pública

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/gruposper.json?term='Cauca'
> ```
##### Ejemplos de respuestas

```json	
{"value":"5 ORGANIZACIONES SOCIALES DEL CAUCA","id":63971},{"value":"ALCALDES MUNICIPALES CAUCA","id":69038}
```
</details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>gruposper/remplazar</code></summary>

Para listar y buscar grupo de personas existentes en la aplicación, esta dispuesta esta ruta. Esta trae registros asociados al modelo Msip::Grupoper.
La estructura de los datos está dada por un objetos con dos propiedades: value, que es el nombre del grupo de personas e id, que es la identificación del grupo de personas. 

##### Parámetros
Es necesario asignar dos parámetros: grupoper_id que hace referencia a la identificación del grupo de persona e victima_idcolectiva que hace referncia a la identificación de la víctima colectiva.  Esto buscará el grupo de persona correspondiente y  mostrará los casos en los que aparece dicho grupo.

El único formato de respuesta establecido es HTML. 

##### Control de Acceso
No disponible para consulta pública.
No disponible para un autenticado como observador de casos
No disponible para un autenticado sin grupo
No disponible para un autenticado con grupo por partes
Disponible para un autenticado operador analista de casos
Disponible para administrador

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/gruposper/remplazar?grupoper_id=71573&victima_idcolectiva=14796
> ```
##### Ejemplos de respuestas

Nombre:  * COMUNIDAD INDIGENA
Anotaciones:
Casos en los que aparece: 18107
</details>

  ------------------------------------------------------------------------------------------
 
## Accesos Informativos

Existen algunas rutas que brindan información importante acerca de elementos de la aplicación. Estas rutas pueden accederse sin necesidad de autenticación alguna y la respuesta obtenida es en formato html. 

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>acercade</code></summary>
 
 Esta ruta permite acceder a la información general de la aplicación suministrada en formato de texto, información de dominios, financiadores, colaboradores. Dispuesta para autenticados y no autenticados. No recibe parámetros adicionales y su único formato es HTML
 </details>
 
<details>
 <summary><code>GET</code> <code><b>/</b></code> 
 <code>controldeacceso</code></summary>
  
Esta ruta permite acceder a la información general sobre los controles de acceso según los roles de los usuarios, está suministrada en una tabla formato de texto. Ruta dispuesta para autenticados y no autenticados. No recibe parámetros adicionales y su único formato es HTML
 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> 
 <code>hogar</code></summary>
  
Esta ruta permite acceder a la página principal de la aplicación (index). Ruta que actualmente es equivalente a acceder a la ruta relativa. Accesible para autenticados y no autenticados. No recibe parámetros adicionales y su único formato es HTML
 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> 
 <code>temausuario</code></summary>
  
Esta ruta permite acceder a la información general sobre los controles de acceso según los roles de los usuarios, está suministrada en una tabla formato de texto. Ruta dispuesta para autenticados y no autenticados. No recibe parámetros adicionales y su único formato es HTML.
##### Ejemplo de respuesta:
```json	
{"fondo":"#ffffff","color_fuente":"#000000","color_flota_subitem_fuente":"#266dd3","color_flota_subitem_fondo":"#ffffff","nav_ini":"#95c4ff","nav_fin":"#266dd3","nav_fuente":"#ffffff","fondo_lista":"#95c4ff","btn_primario_fondo_ini":"#0088cc","btn_primario_fondo_fin":"#0044cc","btn_primario_fuente":"#ffffff","btn_peligro_fondo_ini":"#ee5f5b","btn_peligro_fondo_fin":"#bd362f","btn_peligro_fuente":"#ffffff","btn_accion_fondo_ini":"#ffffff","btn_accion_fondo_fin":"#e6e6e6","btn_accion_fuente":"#000000","alerta_exito_fondo":"#dff0d8","alerta_exito_fuente":"#468847","alerta_problema_fondo":"#f8d7da","alerta_problema_fuente":"#721c24"}
```

 </details>

<details>
 <summary><b>CRUD Bitácoras</b></summary>

Permite la gestión de la tabla bitácoras perteneciente al motor Msip. Es una tabla cuyos registros son acciones las acciones realizadas por usuarios dentro de la aplicación 
<details>
 <summary><code>GET / bitacoras / :id</code></summary>

Permite acceder a listado de bitácoras en formato HTML y JSON. 
##### Parámetros

> | nombre            |  tipo     | tipo de dato      | descripción                         |
> |-------------------|-----------|----------------|-------------------------------------|
> | `filtro[busid]` | Opcional | Entero | Filtro identificación de caso.


##### Control de Acceso
Un usuario administrador puede ver todos los registros de bitácoras.
Un usuario con rol operador, podrá ver sus propios registros.

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/bitacoras?utf8=✓&filtro[busid]=2358&commit=Enviar
> ``` 
##### Ejemplos de respuestas
```json	
[{"id":2388,"fecha":"2021-12-07T16:33:08.000-05:00","ip":"191.102.196.90","usuario_id":10080,"url":"http://nuevo.nocheyniebla.org:3400/sivel2/casos","params":"{\"controller\"=\u003e\"sivel2_gen/casos\", \"action\"=\u003e\"index\"}","modelo":"Sivel2Gen::Caso","modelo_id":0,"operacion":"listar","detalle":"{}","created_at":"2021-12-07T16:33:08.697-05:00","updated_at":"2021-12-07T16:33:08.697-05:00"},{"id":2383,"fecha":"2021-12-07T11:48:33.000-05:00","ip":"191.102.197.42","usuario_id":10080,"url":"http://nuevo.nocheyniebla.org:3400/sivel2/casos/15","params":"{\"controller\"=\u003e\"sivel2_gen/casos\", \"action\"=\u003e\"show\", \"id\"=\u003e\"159968\"}","modelo":"Sivel2Gen::Caso","modelo_id":159968,"operacion":"presentar","detalle":"{}","created_at":"2021-12-07T11:48:33.458-05:00","updated_at":"2021-12-07T11:48:33.458-05:00"}]
```

</details>

<details>
 <summary><code>POST / bitacoras </code></summary>
 
Permite crear registro de bitácoras por parte de un usuario siempre y cuando el usuario_id de la bitácora sea el identificador del usuario creador. Un usuario administrador si podra crear la bitácora con cualquier valor para los parámetros. 

##### Parámetros
Parameters: {"authenticity_token"=>"[FILTERED]", "bitacora"=>{"fecha(3i)"
=>"7", "fecha(2i)"=>"12", "fecha(1i)"=>"2021", "fecha(4i)"=>"18", "fecha(5i)"=>"51", "ip"=>"127.0.0.1", "usuario_id"=>"", "url"=>"lkjpijp", "modelo"=> "Sivel2Gen::Caso", "modelo_id"=>"47", "operacion"=>"listar", "detalle"=>"{nombre: }", "params"=>""}, "commit"=>"Crear"}

</details>

<details>
 <summary><code>GET / bitacoras / nueva</code></summary>

Vista para acceder a formulario de nueva bitácora, responde con un HTML para ingresar la información de la nueva bitácora. Esta vista solo puede ser accedida por un usuario autenticado y con rol administrador.
</details>

<details>
 <summary><code>GET / bitacoras / :id / edita</code></summary>

Vista para acceder a formulario de edición de bitácora, responde con un HTML para ingresar la información de la bitácora la cual se desea editar. En la ruta se especifica el identificador de dicha bitácora. Esta vista solo puede ser accedida por un usuario autenticado y con rol administrador para el caso de cualquier bitácora; y como un usuario con rol operador y con grupo analista de casos para el caso de que la bitácora tenga su campo usuario_id tenga la identificación del usuario editor.

</details>

<details>
 <summary><code>GET / bitacoras / :id</code></summary>

Vista para acceder a la vista de registro de una bitácora, responde con un HTML con la información de la bitácora especificada en la ruta a través de su identificador. Esta vista solo puede ser accedida por:
Un usuario autenticado y con rol administrador para el caso de cualquier bitácora
Un usuario operador con o sin grupo para el caso de que la bitácora tenga su campo usuario_id tenga la identificación del usuario editor.

</details>

<details>
 <summary><code>PATCH / bitacoras / :id</code></summary>
 
Actualizar una parte de un registro de bitácora según parámetros de edición. Esta acción solo podrá ser realizada por un usuario administrador para cualquier registro y por un usuario con rol operador y con grupo analista de casos para el caso de que la bitácora tenga su campo usuario_id tenga la identificación del usuario editor.
</details>

<details>
 <summary><code>PUT / bitacoras / :id</code></summary>

Actualizar completamente un registro de bitácora según parámetros de edición. Esta acción solo podrá ser realizada por un usuario administrador para cualquier registro y por un usuario con rol operador y con grupo analista de casos para el caso de que la bitácora tenga su campo usuario_id tenga la identificación del usuario editor.
</details>

<details>
<summary><code>DELETE / bitacoras / :id</code></summary>

Eliminar completamente un registro de bitácora especificando su identificación en la ruta. Esta acción solo podrá ser realizada por un usuario administrador para cualquier registro y por un usuario con rol operador y con grupo analista de casos para el caso de que la bitácora tenga su campo usuario_id tenga la identificación del usuario editor.
</details>

</details>

------------------------------------------------------------------------------------------
 
## Respaldo
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>respaldo7z</code></summary>

Esta ruta permite acceder a la vista de nuevo respaldo. Una página html donde se puede obtener un respaldo especificando una clave de cifrado.

##### Parámetros
No espera parámetros para acceder a la ruta

##### Control de Acceso
Solamente un administrador tiene permisos para acceder a la ruta y para realizar un respaldo (GET y POST)

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/respaldo7zterm="villa"
> ``` 

</details>

------------------------------------------------------------------------------------------
## Listando Ubicaciones
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>mundep</code></summary>

Es posible obtener un listado de ubicaciones en el formato de departamento y municipio. Esta trae registros asociados al modelo Msip::Ubicacion re construido en dicho formato ejemplo: "SANTANDER DE QUILICHAO / CAUCA".
La estructura de los datos está dada por un objetos con dos propiedades: label, que es el nombre de la ubicacion y value que equivale a la identificación de dicha ubicación. 

##### Parámetros
Es necesario fijar un parámetro en la ruta denominado "term",  que es usado también en autocompletación. Este es un string que va a buscar entre todos los nombres de las ubicaciones alguna coincidencia.

El único formato de respuesta establecido es Json. 

##### Control de Acceso
Cualquier persona autenticada o sin autenticar puede acceder a esta consulta.

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/mundep.json?term="villa"
> ```
##### Ejemplos de respuestas

```json	
{"label":"VILLA CARO / NORTE DE SANTANDER","value":54871},{"label":"VILLA DE LEYVA / BOYACÁ","value":15407},{"label":"VILLA DE SAN DIEGO DE UBATÉ / CUNDINAMARCA","value":25843},{"label":"VILLA DEL ROSARIO / NORTE DE SANTANDER","value":54874},{"label":"VILLA RICA / CAUCA","value":19845},{"label":"VILLAGARZÓN / PUTUMAYO","value":86885},{"label":"VILLAGÓMEZ / CUNDINAMARCA","value":25871},{"label":"VILLAHERMOSA / TOLIMA","value":73870},{"label":"VILLAMARÍA / CALDAS","value":17873},{"label":"VILLANUEVA / BOLÍVAR","value":13873},{"label":"VILLANUEVA / CASANARE","value":85440},{"label":"VILLANUEVA / LA GUAJIRA","value":44874},{"label":"VILLANUEVA / SANTANDER","value":68872},{"label":"VILLAPINZÓN / CUNDINAMARCA","value":25873},{"label":"VILLARRICA / TOLIMA","value":73873},{"label":"VILLAVICENCIO / META","value":50001},{"label":"VILLAVIEJA / HUILA","value":41872},{"label":"VILLETA / CUNDINAMARCA","value":25875}
```
 </details>
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>ubicaciones </code> <code><b>/</b></code><code>nuevo</code></summary>

Crea un nuevo registro para la tabla ubicaciones para el caso que recibe por parámetro a través de caso_id.

Si no se especifica ningún parámetro, retorna un mensaje de "Falta identificación del caso". 
Si se especifica el parámetro correspondiente a la identificación del caso y si la ubicación es creada correctamente, retorna su identificación
##### Ejemplo cURL

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/ubicaciones/nuevo?caso_id=17368
> ```

 </details>
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>tipoclase</code></summary>

Permite obtener un objeto con el nombre del tipo de centro poblado dada la identificación del centro poblado como parámetro.

Si no se especifica ningún parámetro, retorna un objeto de "{"nombre":""}. 
Si se especifica el parámetro correspondiente a la identificación del centro poblado y si el centro poblado existe, se obtiene en el objeto el nombre del tipo de centro poblado. 
##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/tipoclase?id=15308
> ```
##### Ejemplo de respuesta

```json
[{"nombre":"CENTRO POBLADO"}
```
</details>
 
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>ubicacionespre_mundep</code></summary>

Permite obtener un objeto con las coincidencias encontradas en la tabla ubicacionespre con el formato municipio/departamento. Esta ruta es utilizada para autocompletación y recibe como parámetro :term, una cadena de texto donde se buscarán las coincidencias. Importante: la única respuesta exitosa es para el formato JSON

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/ubicacionespre_mundep.json?term="villa"
> ```
##### Ejemplo de respuesta

```json
[{"value":"VILLA CARO / NORTE DE SANTANDER","id":1335},{"value":"VILLA DE LEYVA / BOYACÁ","id":788},{"value":"VILLA DE SAN DIEGO DE UBATÉ / CUNDINAMARCA","id":1391},{"value":"VILLA DEL ROSARIO / NORTE DE SANTANDER","id":1344},{"value":"VILLA RICA / CAUCA","id":1308},{"value":"VILLAGARZÓN / PUTUMAYO","id":1356},{"value":"VILLAGÓMEZ / CUNDINAMARCA","id":1336},{"value":"VILLAHERMOSA / TOLIMA","id":1334},{"value":"VILLAMARÍA / CALDAS","id":1340},{"value":"VILLANUEVA / BOLÍVAR","id":1341},{"value":"VILLANUEVA / CASANARE","id":825},{"value":"VILLANUEVA / LA GUAJIRA","id":1345},{"value":"VILLANUEVA / SANTANDER","id":1337},{"value":"VILLAPINZÓN / CUNDINAMARCA","id":1342},{"value":"VILLARRICA / TOLIMA","id":1343},{"value":"VILLAVICENCIO / META","id":405},{"value":"VILLAVIEJA / HUILA","id":1338},{"value":"VILLETA / CUNDINAMARCA","id":1346}]
```
 </details>

<details>
 <summary><code>CRUD ubicacionespre</code></summary>

En la tabla ubicacionespre se almacenan los registros de ubicaciones completos desde un país solo, pasando por país/departamento, país/departamento/municipio y país/departamento/municipio/centro poblado. La peticiones pueden tener respuestas en formato HTML y en formato JSON. A continuación se presentan las posibles peticiones.
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>ubicacionespre</code></summary>

Petición que permite listar las ubicacionespre, puede recibir un parámetro :term utilizado en autocompletación para buscar coincidencias de una cadena de texto con una ubicación. 

##### Control de acceso
Cualquier usuario autenticado o no, puede consultar el listado de ubicacionespre.

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/ubicacionespre.json?term=%22PALOMERA%22
> ```
##### Ejemplo de respuesta

```json
[{"value":"LA PALOMERA / CALOTO / CAUCA / COLOMBIA","id":1929},{"value":"LA PALOMERA / GUADALAJARA DE BUGA / VALLE DEL CAUCA / COLOMBIA","id":13292},{"value":"LA PALOMERA / SANTANDER DE QUILICHAO / CAUCA / COLOMBIA","id":13481}]
```
 </details>

<details>
 <summary><code>POST</code> <code><b>/</b></code> <code>ubicacionespre</code></summary>
 
Crea un nuevo registro para ubicacionespre a través de los siguientes parámteros:
id: integer, nombre: string, pais_id: integer, departamento_id: integer, municipio_id: integer, clase_id: integer, lugar: string, sitio: string, tsitio_id: integer, latitud: float, longitud: float, created_at: datetime, updated_at: datetime, nombre_sin_pais: string

##### Control de acceso
Crear un nuevo registro de ubicacionpre solo puede realizarse por parte de un usuario administrador

##### Ejemplo cURL

> ```javascript
>  curl -X POST http://nuevo.nocheyniebla.org:3400/sivel2/ubicacionespre  id=14782&nombre="BARRANCOMINAS / BARRANCOMINAS / GUAINÍA / COLOMBIA"&pais_id=170&departamento_id= 56&municipio_id= 594& clase_id= 13064&created_at="2021-12-08"&updated_at: "2021-12-08"&nombre_sin_pais= "BARRANCOMINAS / BARRANCOMINAS / GUAINÍA"

> ```
##### Ejemplo de respuesta
STATUS 200: OK

 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>ubicacionespre</code><code><b>/</b></code><code>nueva</code></summary>
 
Obtener vista para crear nueva ubicacionpre. Retorna una vista HTML con un formulario para crear un nuevo registro. Esta vista solo puede ser accedida por un usuario administrador. 
 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>ubicacionespre</code><code><b>/</b></code><code>:id</code><code><b>/</b></code><code>edita</code></summary>
 
Vista para acceder a formulario de edición de ubicacionpre, responde con un HTML para ingresar la información de la ubicacionpre la cual se desea editar. En la ruta se especifica el identificador. Esta vista solo puede ser accedida por un usuario autenticado y con rol administrador.

 </details>
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>ubicacionespre</code><code><b>/</b></code><code>:id</code></summary>

Ruta para acceder a la vista de registro de un ubicacionpre, responde con un HTML con la información de la ubicacionpre especificada en la ruta a través de su identificador. Esta vista puede ser accedida por cualquier usuario autenticado o no.

 </details>

<details>
 <summary><code>PATCH</code> <code><b>/</b></code> <code>ubicacionespre</code><code><b>/</b></code><code>:id</code></summary>

Actualizar una parte de un registro de ubicacionpre según parámetros de edición. Esta acción solo podrá ser realizada por un usuario administrador.

 </details>

<details>
 <summary><code>PUT</code> <code><b>/</b></code> <code>ubicacionespre</code><code><b>/</b></code><code>:id</code></summary>

Actualizar completamente un registro de bitácora según parámetros de edición. Esta acción solo podrá ser realizada por un usuario administrador.
 </details>
<details>
 <summary><code>DELETE</code> <code><b>/</b></code> <code>ubicacionespre</code><code><b>/</b></code><code>:id</code></summary>

Eliminar completamente un registro de bitácora especificando su identificación en la ruta. Esta acción solo podrá ser realizada por un usuario administrador.
 </details>
 
 </details>
 
 ------------------------------------------------------------------------------------------
 
## Listando Anexos

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>anexos</code><code><b>/</b></code><code>:id</code></summary>
 
Esta ruta permite consultar un anexo específico guardado en la aplicación a través de su identificación. Es posible que hayan anexos en difernetes formatos, documentos o imágenes. El parámetro de identificación que se tiene que especificar es el campo id del objeto correspondiente de la tabla Msip::Anexo.
Control de acceso: Cualquier persona autenticada puede acceder a descargar un anexo. Para la consulta pública no se autoriza descargar anexo.
Al hacer la petición se descarga automáticamente el anexo y no hay redireccionamiento. 
##### Ejemplo cURL

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/anexos/descarga_anexo/104
> ```

</details>


 ------------------------------------------------------------------------------------------
 
## Listando organizaciones sociales
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>orgsociales</code></summary>

Los parámetros que se pueden establecer en la url de la petición son los que hacen referencia al filtro y los cuales se describen a continuación
 ##### Parámetros para filtros

> | Parámetro    | Tipo y Accesos                   | Ejemplo	  | 
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `:busid`         | Integer / AUT      | Persona con id 145: `filtro[busid]=145`
> | `:busgrupoper_id`         |Integer  / AUT      |Identificación del grupo es 1:  `filtro[busgrupoper_id]=1`
> | `:bussectororgsocial_ids`         |String  / AUT      |Identificación de sector de organización social es 101  `filtro[bussectororgsocial_ids]=101`
> | `:bushabilitado`         |String [Si, No, Todos] / AUT       | Solo habilitados: `filtro[bushabilitado]=Si`
> | `:buscreated_atini`         |String / AUT        |Fecha inicial es 1 de Nov de 2021: `filtro[buscreated_atini]=2021-11-01`
> | `:buscreated_atfin`         |String / AUT        |Fecha final es 20 de Nov de 2021: `filtro[buscreated_atfin]=2021-11-20`

 ##### Respuestas

> | código http    | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `application/html;charset=UTF-8` / `application/json;charset=UTF-8`     | Página html / Objeto JSON 
> | `400`         |Error        | (Bad Request) Los datos enviados son incorrectos o hay datos obligatorios no enviados
> | `401`         | Error        | (Unauthorized) No hay autorización para llamar al servicio
> | `404`         | Error`        | (NotFound) No se encontró información
> | `500`         | Error        | Error en servidor                                                   |

##### Ejemplo cURL

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/orgsociales.json?utf8=✓&filtro[busid]=&filtro[busgrupoper_id]=102&filtro[bussectororgsocial_ids]=101&filtro[bushabilitado]=Si&filtro[buscreated_atini]=2021-11-01&filtro[buscreated_atfin]=2021-11-20&filtrar=Filtrar
> ```
##### Ejemplo de respuesta
La respuesta es una tabla html en donde la primera columna es el criterio de desagregación, la segunda y tercera el filtro de geolocalización (departamento y/o municipio) y la última el número de las víctimas por fila. 
```json
[{"id":2,"grupoper_id":102,"telefono":"3116494967","fax":"","direccion":"Calle 13 A # 11 -99","pais_id":170,"web":"","created_at":"2021-11-10T12:44:20.793-05:00","updated_at":"2021-11-10T12:44:20.793-05:00","fechadeshabilitacion":null}]
```

##### Control de acceso
Actualmente, cualquier usuario autenticado con cualquiera de los tres roles (Administrador, Directivo y Operador), puede consultar las organizaciones sociales en su totalidad. Sin embargo, un operador analista no puede eliminar organizaciones sociales existentes más si editar y un operador observador únicamente puede ver los registros sin editar o eliminar. Un usuario desde la consulta web pública o sin autenticarse no acceder a ningún registro.  
</details>

-----------------------------------------------------------------------------------------
 
## Gestionando tablas básicas 

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>tablasbasicas</code></summary>

Esta petición trae un listado de tablas básicas utilizadas por los formularios  y la aplicación en general. No recibe ningún parámetro adicional y su respuesta únicamente será en html de ser exitosa y tener la autorización necesaria.
Las tablas básicas únicamente pueden ser accedidas tienen un control de acceso que depende del tipo de las mismas:

- Rol Administrador: Puede acceder, editar, actualizar, eliminar datos de cualquier tabla básica propias de sivel2 o de Msip. 
- Rol autenticado: No puede visualizar los datos, ni consultar información de cualquier tabla básica salvo que sea geográfica, sin poder editar.
- Consulta pública: Únicamente puede visualizar los datos de las tablas básicas geográficas: País, departamento, municipio y centro poblado. 

 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>admin/tablabasica</code></summary>

A través de esta petición es posible obtener los datos de una tabla básica especifica, escribiendo la ruta admin, seguida del nombre de la tabla básica en plural. Esta petición puede estar acompañada de los siguientes parámetros pertenecientes a filtro:

##### Parámetros

> | nombre            |  tipo     | tipo de dato      | descripción                         |
> |-------------------|-----------|----------------|-------------------------------------|
> | `filtro[busid]` |  Requerido | Integer   | Buscar por identificación|
> | `filtro[busnombre]` |  Requerido | String   | Buscar por nombre  |
>  | `filtro[busobservaciones]` |  Requerido | String   | Buscar por algún texto en las observaciones  |## Gestionando tablas básicas 

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/admin/categorias?filtro[busid]=23&filtro[busnombre]=ABORTO&filtro[busobservaciones]=OBSER&filtro[busfechacreacionini]=2021-10-01&filtro[busfechacreacionfin]=2021-10-28&filtro[bushabilitado]=Todos&filtrar=Filtrar
> ```
##### Respuestas
El listado de datos de una tabla básica puede obtenerse en dos formatos
> | código http   | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `text/json;charset=UTF-8`        | Página HTML / Objeto JSON                                                     |
> | `400`         | `application/json`                | `{"code":"400","message":"Bad Request"}`                            |

 </details>
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>admin/tablabasica/:id</code></summary>

Es posible obtener un único valor de una tabla básica especificando en la ruta el dentificador de la tabla. La respuesta a esta petición está disponible en formato HTML y JSON. Por ejemplo suponiendo que se tiene la siguiente petición:
> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/admin/antecedentes/6.json
> ```
Su respuesta ser así: 
```json	
{"id":6,"nombre":"ALLANAMIENTO","observaciones":null,"fechacreacion_localizada":"29/ene/2001","fechadeshabilitacion_localizada":null}`
```
 </details>
 
## Listando lugares preliminares de disposición irregular de cadáveres

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>lugarespreliminares</code> </summary>
 
 A través de esta petición es posible obtener los datos del listado de registros de luagres preliminares de disposición irregular de cadáveres, modelo que hace parte del motor Apo214, el cual se asocia con varias tablas básicas de ese motor utilizadas para una mejor implementación dell formulario y facilitar consultas.  Esta petición puede estar acompañada de los siguientes parámetros pertenecientes a filtro:
Un ejemplo de una petición es:

> ```javascript
>  curl -X GET http://rbd.nocheyniebla.org:3400/sivel2/lugarespreliminares.json
> ```
##### Respuestas
El listado de datos de una tabla básica puede obtenerse en dos formatos
> | código http   | tipo de contenido                     | respuesta                                                          |
> |---------------|-----------------------------------|---------------------------------------------------------------------|
> | `200`         | `text/json;charset=UTF-8`        | Página HTML / Objeto JSON                                                     |
> | `400`         | `application/json`                | `{"code":"400","message":"Bad Request"}`                            |

Y los objetos de respuesta JSON a esta petición son de la siguiente forma:
```json	
[{"id":4,"fecha":"2021-11-10","codigositio":"191030","created_at":"2021-11-06T19:39:08.247-05:00","updated_at":"2021-11-10T16:28:41.551-05:00","nombreusuario":"sivel2","organizacion":"organizacion ejemplo ","ubicacionpre_id":null,"persona_id":101,"parentezco":"AB","grabacion":false,"telefono":"35468489","tipotestigo_id":null,"otrotipotestigo":"","hechos":"","ubicaespecifica":"","disposicioncadaveres_id":null,"otradisposicioncadaveres":"","tipoentierro_id":null,"min_depositados":null,"max_depositados":null,"fechadis":null,"horadis":"1999-12-31T19:39:00.000-05:00","insitu":true,"otrolubicacionpre_id":null,"detallesasesinato":"","nombrepropiedad":"","detallesdisposicion":"","nomcomoseconoce":"","elementopaisaje_id":null,"cobertura_id":null,"interatroprevias":"","interatroactuales":"","usoterprevios":"","usoteractuales":"","accesolugar":"","perfilestratigrafico":"","observaciones":"","procesoscul":"","desgenanomalia":"","evaluacionlugar":"","riesgosdanios":"","archivokml_id":null}]`
```
 </details>
 
## Gestionando plantillas

Sivel2 tiene actualmente  2 tipos de llenadores de plantillas:
-   Para llenar una plantilla ODS con datos de un listado (vista index), que se supone puede demorarse en generar una conjunto grande de datos. (Plantillahcm)
-   Para llenar una plantilla ODS con datos de un resumen (vista show), que suponemos se genera rápido. (Plantillahcr)
<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>plantillashcm</code> </summary>
 
Es posible por medio de esta petición, obtener el listado de plantillas creadas para listados. El único parámetro de filtro es el identificador <code>filtro[:busid]</code>. La respuesta está disponible en HTML y JSON y los controles de accceso son los siguientes:

- Rol administrador: Puede crear, consultar, editar, actualizar y eliminar plantillas de listado
- Usuario autenticado no administrador: Puede leer las plantillas sin editar ni eliminar
- Consulta pública: No puede acceder a las plantillas 
 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>plantillashcm/:id</code> </summary>
 
 Con esta ruta realizamos una petición a una plantilla especifica indicando el identificador. la respuesta esta disponible en HTML o bien un objeto JSON y los permisos de control de acceso son los mismos mencionados para la petición del listado. Un ejemplo de una petición a una plantillahcm puede visualizarse así:
 
 > ```javascript
>  curl  -X GET http://rbd.nocheyniebla.org:3400/sivel2/plantillahcm/1.json
> ```
Obteniendo una respuesta así:
```json	
{"id":1,"ruta":"plantillas/ReporteTabla.ods","fuente":"Pasos de Jesús","licencia":"Dominio Público","vista":"Caso","nombremenu":"Listado genérico de casos","formulario":[],"filainicial":6}
```
 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>plantillashcr</code> </summary>
 
Es posible por medio de esta petición, obtener el listado de plantillas creadas para registros únicos. El único parámetro de filtro es el identificador <code>filtro[:busid]</code>. La respuesta está disponible en HTML y JSON y los controles de accceso son los siguientes:

- Rol administrador: Puede crear, consultar, editar, actualizar y eliminar plantillas de listado
- Usuario autenticado no administrador: Puede leer las plantillas sin editar ni eliminar
- Consulta pública: No puede acceder a las plantillas 
 </details>

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>plantillashcr/:id</code> </summary>
 
 Con esta ruta realizamos una petición a una plantilla especifica indicando el identificador. la respuesta esta disponible en HTML o bien un objeto JSON y los permisos de control de acceso son los mismos mencionados para la petición del listado. Un ejemplo de una petición a una plantillahcm puede visualizarse así:
 
 > ```javascript
>  curl  -X GET http://rbd.nocheyniebla.org:3400/sivel2/plantillahcr/1.json
> ```
Obteniendo una respuesta así:
```json	
{"id":1,"ruta":"plantillas/reporte_un_caso.ods","fuente":"fuenet","licencia":"","vista":"Caso","nombremenu":"Ejemplo","formulario":[],"campoplantillahcr":[]}
```
</details>

<details>
 <summary><code>GET / sis / arch </code></summary>
Presenta una vista con carpetas existentes y si es un usuario administrador tiene una funcionalidad para crear una carpeta nueva de archivos dentro de la aplicación.  

##### Ejemplo url
> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/sis/arch
> ```

##### Ejemplo de respuestas
La respuesta es una página HTML con las carpetas.

##### Control de Acceso
Usuarios no autenticados no pueden visualizar carpetas
Usuarios autenticados con rol operador pueden unicamente visualizar las carpetas más no crear
Usuarios administradores tienes todos los permisos.
 </details>
 
<details>
 <summary><code>POST / sis / nueva </code></summary>
Permite crear una nueva carpeta en la nube de la aplicación. 

##### Ejemplo url
> ```javascript
>  curl -X POST http://nuevo.nocheyniebla.org:3400/sivel2/sis/nueva
> ```

##### Ejemplo de respuestas
La respuesta es un HTML con el listado de carpetas con la nueva carpeta creada.

##### Control de Acceso
Solo usuarios administradores tiene permiso para crear carpeta.
 </details>
 
<details>
 <summary><code>POST / sis / nuevo </code></summary>
Permite crear un nuevo archivo en la nube de la aplicación. 

##### Ejemplo url
> ```javascript
>  curl -X POST http://nuevo.nocheyniebla.org:3400/sivel2/sis/nuevo
> ```

##### Ejemplo de respuestas
La respuesta es un HTML con el listado de carpetas con el archivo nuevo creado.

##### Control de Acceso
Solo usuarios administradores tiene permiso para crear archivos.
 </details>
 
 <details>
 <summary><code>POST / sis /actleeme </code></summary>
Permite actualizar ruta o remplazar archivo LEEME.md

##### Ejemplo url
> ```javascript
>  curl -X POST http://nuevo.nocheyniebla.org:3400/sivel2/sis/actleeme
> ```

##### Control de Acceso
Solo usuarios administradores tiene permiso para actleeme.
 </details>

 <details>
 <summary><code>GET / plantillashcm / importadatos </code></summary>
Permite actualizar ruta o remplazar archivo LEEME.md

##### Ejemplo url
> ```javascript
>  curl -X GET http://nuevo.nocheyniebla.org:3400/sivel2/plantillashcm/importadatos
> ```
##### Ejemplo de respuestas
La respuesta es un HTML con la vista del formulario para importar datos para plantillas hcm.
##### Control de Acceso
Solo usuarios administradores tiene permiso para importar datos en plantillashcm.
 </details>
 <details>
 <summary><code>POST / plantillashcm / importadatos </code></summary>
Petición que importa datos para nuevas plantillashcm

##### Ejemplo url
> ```javascript
>  curl -X POST http://nuevo.nocheyniebla.org:3400/sivel2/plantillashcm/importadatos
> ```
##### Ejemplo de respuestas
La respuesta es un HTML con la vista del formulario para importar datos para plantillas hcm.
##### Control de Acceso
Solo usuarios administradores tiene permiso para importar datos en plantillashcm.
 </details>
