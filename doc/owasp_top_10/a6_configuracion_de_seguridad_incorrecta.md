# Prevención a configuración de seguridad incorrecta

Deben implementarse procesos seguros de instalación, incluyendo:

* En la documentación de las fuentes se hacen recomendaciones para
  la instalación de manera segura para toda la pila de software en
  su versión más reciente desde sistema operativo (adJ), pasando por 
  servidor web (nginx), motor de bases de datos (PostgreSQL), lenguaje 
  (ruby), marco de trabajo (rails) y aplicación. Desarrollamos la
  distribucíon adJ que incluye todos estos componentes y documentación
  detallada que se actualiza para emplear los componentes más recientes
  cada 6 meses.  En nuevas instalaciones se centraliza la configuración
  de la aplicación en un archivo `.env` en el que quien instala debe
  especificar usuario en sistema operativo, usuario en base de datos,
  clave en base de datos, nombres de bases de datos, ubicación de la 
  aplicación, etc. Una vez en operación queda habilitado solo un
  usuario administrador sivel2 con clave sivel2, que debe cambiarse
  en sitios de producción por un usuario real con su clave.
* En la distribución adJ se procura incluir sólo lo necesario
  para un servidor que pueda alojar SIVeL2 u otro de los sistemas
  de información activos que desarrolla Pasos de Jesús, con posibilidad 
  de ser sistema de desarrollo.
* Se recomienda actualizar con regularidad del repositorio github.
* La aplicación tiene una arquitectura bastante segmentada porque está
  dividida la funcionalidad en motores.
* Las cabeceras de seguridad servidas por un sitio en producción con
  la configuración predeterminada incluyen:
```
  HTTP/1.1 200 OK
  Server: nginx
...
  X-Frame-Options: ALLOW
  Cache-Control: max-age=0, private, must-revalidate
...
  X-Request-Id: 07e542d2-dd8d-42ad-a259-e5949ca66268
  X-Runtime: 0.956912
  Vary: Origin
  Access-Control-Allow-Methods: GET, POST, OPTIONS
  Access-Control-Allow-Headers:
  DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range
  Access-Control-Expose-Headers: Content-Length,Content-Range

* Envíe directivas de seguridad a los clientes (por ej. cabeceras de
          seguridad).
* Utilice un proceso automatizado para verificar la efectividad de los
            ajustes y configuraciones en todos los ambientes.
