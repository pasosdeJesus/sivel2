# API de casos de SiVel2
Esta es la documentación oficial de la API de casos de la aplicación siVel2. Aquí están descritas todas las posibles peticiones y consultas posibles, los parámetros establecidos, respuestas posibles y controles de acceso definidos en la configuración. 
Un susario puede consumir de la API tanto las generalidades básicas de un conjunto de casos, como también un caso con todos los detalles del mismo.  Esta API está siendo utilizada para el reporte de casos en la aplicación pero igualmente esta siendo consumida por servicios como mapas y reportes completos de informes en planillas. Se puede generar reportes en diferentes formatos: JSON, XRLAT (XML) y HTML..
- Inspirado por docuemtación Swagger API en estilo y estructura: https://petstore.swagger.io/#/pet
------------------------------------------------------------------------------------------

## Listando casos existentes 

<details>
 <summary><code>GET</code> <code><b>/</b></code> <code>casos</code></summary>

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
> | `:contextovictima_id`         |Integer / AUT     |El contexto de vćitima es Falso positivo: `filtro[contextovictima_id]=1`  
> | `:orientacionsexual`         |String / AUT     |La orientación sexual es Heterosexual: `filtro[contextovictima_id]=H`                                          
> | `:inc_casoid`         |Integer / AUT     |Incluir la identificación del caso en el reporte: `filtro[inc_casoid]=1`  
> | `:inc_fecha`         |Integer / CP / AUT     |Incluir la fecha del caso en el reporte: `filtro[inc_casoid]=1`  
> | `:inc_ubicaciones`         |Integer / CP / AUT     |Incluir las ubicaciones del caso: `filtro[inc_ubicaciones]=1`
> | `:inc_presponsables`         |Integer / CP / AUT     |Incluir los presuntos responsables del caso en el reporte: `filtro[inc_presponsables]=1`    
> | `:inc_tipificacion`         |Integer / CP / AUT     |Incluir la tipificación del caso en el reporte: `filtro[inc_tipificacion]=1`  
> | `:inc_victimas`         |Integer / CP / AUT     |Incluir las victimas del caso en el reporte: `filtro[inc_victimas]=1`  
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
>  curl -X GET http://nodos.pasosdejesus.org:2400/sivel2/casos.html?filtro[q]=&filtro[departamento_id]=17&filtro[municipio_id]=1152&filtro[clase_id]=&filtro[inc_ubicaciones]=1&filtro[orden]=ubicacion&filtro[fechaini]=&filtro[fechafin]=&filtro[inc_fecha]=1&filtro[presponsable_id][]=&filtro[inc_presponsables]=1&filtro[inc_tipificacion]=1&filtro[nombres]=&filtro[apellidos]=&filtro[inc_victimas]=1&filtro[sexo]=&filtro[orientacionsexual]=&filtro[rangoedad_id]=&filtro[sectorsocial_id]=&filtro[organizacion_id]=&filtro[profesion_id]=&filtro[victimacol]=&filtro[inc_victimacol]=1&filtro[descripcion]=&filtro[inc_memo]=1&filtro[conetiqueta1]=true&filtro[etiqueta1]=&filtro[conetiqueta2]=true&filtro[etiqueta2]=&filtro[usuario_id]=&filtro[fechaingini]=&filtro[fechaingfin]=&filtro[codigo]=&filtro[inc_casoid]=1&filtro[paginar]=1&filtro[disgenera]=reprevista.html&idplantilla=reprevista&formato=html&formatosalida=html&commit=Enviar
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
SIVeL 2 mostrará el reporte completo siguiendo el docmuneto DTD ubicado en [http://sincodh.pasosdejesus.org/relatos/relatos-099.dtd](http://sincodh.pasosdejesus.org/relatos/relatos-099.dtd)
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
 <summary><code>GET</code> <code><b>/casos/ {id}</b></code> <code>(obtener un caso específico según el id proporcionado)</code></summary>

##### Parámetro

> | nombre            |  tipo     | tipo de dato      | descripción                         |
> |-------------------|-----------|----------------|-------------------------------------|
> | `id` |  requerido | Integer   | El identificador específico del caso        |

Para conusltar un caso en detalle, SIVeL 2 proporciona los formatos html, json y xrlat (xml). Las rutas de estas vistas se obtienen al agregar la extensión correspondiente al final de  sivel2/casos/id.[extensión]. Para el caso de la extensión JSON. SIVeL 2 responde con los detalles del caso con un objeto JSON con una sola propiedad caso cuyo valor es un objeto con las propiedades:

id: Identificación, titulo: título del caso, hechos: Descripción o memo del caso, fecha, hora, departamento principal, municipio principal, centro_poblado principal, presponsables: un objeto que puede tener varios ítems, uno por presunto responsable, la propiedad de cada uno será la identificación del presunto responsable y su valor será el nombre victimas: un objeto que puede tener varios ítems, uno por víctima individual del caso, la propiedad de cada uno será la identificación de la víctima y su valor será los nombres de la víctima seguido de un espacio y los apellidos.
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
 <summary><code>GET</code> <code><b>/casos/cuenta</b></code><code> (Trae conteo de casos en un intervalo de fechas)</code></summary>

Se ha construido también una ruta para poder obtener mediante un arreglo el número total de casos por fecha y por departamento.
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
 <summary><code>Resumen control de accesos</code><code>(permisos)</code></summary>
 
 -  Consulta pública:
	 - Consultar hasta 2000 registros en la API (puede usar los filtros para disminuir el número de registros)
	 - Consultar un caso en formato HTML, JSON y XML
	 - Buscar casos con los parámetros limitados a la consulta pública
	 - Contar casos
 - Usuario autenticado:
	 - Consulta listado de casos ilimitado
	 - Consultar un caso en formato HTML, JSON y XML
	 - Buscar casos con los parámetros para usuario autenticado
	 -  Contar casos
</details>

------------------------------------------------------------------------------------------
