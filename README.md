# SIVeL2 #

## Bienvenido al código fuente de SIVeL2 ##
Sistema de Información de Violencia Política en Línea versión 2


[![Revisado por Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com) Pruebas y seguridad: [![Estado Construcción](https://gitlab.com/pasosdeJesus/sivel2/badges/sivel2.0/pipeline.svg)](https://gitlab.com/pasosdeJesus/sivel2/-/pipelines?page=1&scope=all&ref=sivel2.0) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) 

![Logo de sivel2](https://raw.githubusercontent.com/pasosdeJesus/sivel2/main/app/assets/images/logo.jpg)

## Sobre SIVeL2

SIVeL2 es una aplicación web para manejar casos de violencia política y desaparición.  Es segura y de fuentes abiertas.  Su desarrollo es liderado por el colectivo [Pasos de Jesús](https://www.pasosdeJesus.org).

Esta aplicación web es usada o incluida en sistemas de información de varias organizaciones que documentan casos de violencia socio política como las de la Red de Bancos de Datos, el Banco de Datos del CINEP/PPP, JRS-Colombia, CODACOP, ASOM, IAP, ANZORC entre otras.

Te invitamos a ver el manual de usuario en: <https://docs.google.com/document/d/1xr1vtkfpWdpM_VrEbHacm44NiMPCzAIcRUS1ENoBrQU/edit?usp=sharing>

Puedes interactuar con una instalación de demostración en:
<https://defensor.info/sivel2>

Si necesitas una instancia de SIVeL2 para tu organización no gubernamental, o necesitas un sistema de información o incluir y adaptar SIVeL2 en el sistema de información de tu organización por favor revisa <https://defensor.info>.

Si tienes una idea de como mejorar SIVeL2 te invitamos a proponerla con la categoría Idea en <https://github.com/pasosdeJesus/sivel2/discussions>

Si quieres votar para que se implemente el requerimiento que necesitas más rápido te invitamos a suscribirte y votar en <https://cifrasdelconflicto.org>

Si quieres desplegar tu propia instalación de SIVeL2 mira más adelante este documento.

Si desea reportar un problema con sivel2 o conocer del desarrollo de esta aplicación por favor revisa:
* Reportar problemas: <https://github.com/pasosdeJesus/sivel2_gen/issues>
* Reportar una falla de seguridad: <https://github.com/pasosdeJesus/sivel2/blob/main/SECURITY.md>
* Tableros de seguimiento al desarrollo: <https://github.com/pasosdeJesus/sivel2_gen/projects>

Si quieres ayudar a mejorar esta aplicación de fuentes abiertas te recomendamos el repositorio del motor [sivel2_gen](https://github.com/pasosdeJesus/sivel2_gen).  Desde Pasos de Jesús estaremos atentos a quienes hagan aportes para
proponerles oportunidades labores cuando las haya.


## Documentación para administradores que despliegan y mantienen en operación la aplicación

### Requisitos 📋

Ver <https://github.com/pasosdeJesus/sip/blob/main/doc/requisitos.md>
Además si vas a desplegar en producción:
* nginx (>=1.18)

### Probar operación en modo de desarrollo 🔧

* Crea un usuario para PostgreSQL como se explica en 
  <https://github.com/pasosdeJesus/sip/blob/main/doc/aplicacion-de-prueba.md>
  (si dejas el nombre `sipdes` se te facilitarán los siguientes pasos)
* Ubica las fuentes en un directorio, por ejemplo en `/var/www/htdocs/sivel2/`
* Asegúra que las gemas estén instaladas. En el caso de adJ en 
  `/var/www/bundler/ruby/3.1/` siguiendo las instrucciones de 
  <http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby>
  y en el directorio con fuentes asegúrese de tener el archivo `.bundle/config`
  con contenido:
  ```
  ---
  BUNDLE_PATH: "/var/www/bundler"
  BUNDLE_DISABLE_SHARED_GEMS: "true"
  ```
* El archivo `Gemfile` contiene el listado de todas las dependencias a 
  instalar en los distinto ambientes de ejecución. Instala las gemas que 
  se especifican en tal archivo con:
  ```sh
  bundle install
  ```
  (Si quisieras actualizar las dependencias de la aplicación, ejecuta `bundle update; bundle install`)
  
  Si se interrumpe el proceso por problemas de permisos en instalación de una 
  gema, instálala como en el siguiente ejemplo (cambiando la gema y la versión):
  ```sh
  doas gem install --install-dir /var/www/bundler/ruby/3.1/ bindex -v 0.7.0
  ```
* Copia y de requerirlo modifique las plantillas:
```sh
  for i in `find . -name "*plantilla"`; do n=`echo $i | sed -e "s/.plantilla//g"`; if (test ! -e "$n") then {echo $n; cp $i $n; } fi; done 
```
  Estas plantillas dejan la aplicación en el URL /sivel2/ (tendrías que 
  modificarlas si prefiere una raíz de URL diferente, ver
  <https://github.com/pasosdeJesus/sip/blob/main/doc/punto-de-montaje.md> )

  Lo mínimo que debes establecer es el usuario PostgreSQL, su clave y 
  los nombres de las bases de datos (desarrollo, pruebas y producción) que configuraste en 
  PostgreSQL en `config/database.yml` (también es recomendable que agregue el
  usuario y la clave en el archivo `~/.pgpass`).

* Las migraciones del directorio `db/migrate` de `sivel2_gen` permiten 
  migrar una SIVeL 1.2, actualizando estructura y agregando datos que hagan 
  falta.
  Para actualizar un SIVeL 1.2 saca copia a la base, configura los datos de la 
  copia en `config/database.yml` y ejecuta:
  ```sh
  bin/rails db:migrate
  bin/rails sip:indices
  ```
  Si vas a empezar con una base nueva ```sivel2gen_des``` como usuario de 
  PostgreSQL `sipdes`:
  ```sh
  createdb -U sipdes -h /var/www/var/run/postgresql/ sivel2gen_des
  ```
  y desde el directorio de la aplicación:  
  ```sh
  bin/rails db:setup
  bin/rails db:migrate
  bin/rails sip:indices
  ```
* Si no lo has hecho instala `yarn` para manejar paquetes javascript:
  ```sh
  doas pkg_add bash
  ftp -o- https://yarnpkg.com/install.sh | bash
  . ~/.profile
  ```
* Instala las librerías Javascript requeridas al lado del cliente con:
```sh
  CXX=c++ yarn install
  ```
* Crea un enlace a `public/packs` desde la carpeta `public` apropiada para el punto de montaje. 
  Por ejemplo si está empleando el punto de montaje por omisión `/sivel2/` sería:
```sh
  mkdir -p public/sivel2
  cd public/sivel2
  ln -s ../packs .
  cd ../..
  ```
* Para verificar que se están generando bien los recursos ejecuta:
```sh
  rm -rf public/sivel2/assets/* public/sivel2/packs/*
  bin/rails assets:precompile --trace
```
  y después verifica que se están poblando bien los directorios `public/sivel2/assets` y `public/sivel2/packs`
* Lanza la aplicación en modo de desarrollo. En el siguiente ejemplo el 
  parametro `-p` indica el puerto por el cual escuchará la aplicación 
  y el parámetro `-b` indica la dirección IP como **0.0.0.0**
 para que se pueda acceder desde cualquiera de las IPs configuradas en las interfaces de red:
```sh
  bin/rails s -p 2300 -b 0.0.0.0
```
* Examina con un navegador que tenga habilitadas las galletas (cookies) en el 
  puerto 2300: `http://127.0.0.1:2300/sivel2`.  (Por eso si usas el 
  navegador `w3m` añada la opción `-cookie`) 
* Cuando quieras detener basta que de Control-C o que busques el
  proceso con ruby que corre en el puerto 3000 y lo elimines con `kill`:
  ```sh
  ps ax | grep "ruby.*2300"
  kill 323122
  ```
* En este modo es recomendable borrar recursos precompilados 
  ```sh
  rm -rf public/assets/*
  ```

### Pruebas ⚙️

Dado que se hacen pruebas a modelos, rutas, controladores y vistas en 
`sivel2_gen`, en `sivel2` sólo se implementan pruebas de control de acceso con minitest 
y pruebas al sistema con sideex.

Puede ejecutar las pruebas de control de acceso con:
```sh
CONFIG_HOSTS=www.example.com bin/rails test
```
Al respecto de modificar o crear pruebas con mini-test
recomendamos  <https://github.com/pasosdeJesus/sip/blob/main/doc/pruebas-con-minitest.md>.

Para ejecutar las pruebas del sistema con Sideex, ejecuta la aplicación en modo de desarrollo
y desde el navegador compatible con Chrome en el que la visualiza, instala la extensión sideex 
(http://www.sideex.org/), carga las suits de prueba de la carpeta `test/sideex` y correlas.
La mayoría de pruebas deberían pasar (en ocasiones algunas no pasan por demoras en la aplicación para servir
páginas o responder AJAX, pero si ejecuta varias veces eventualmente mejorando servidor,
cliente o conexión entre ambos, deberían pasar).


### Despliegue en sitio de producción con unicorn ⌨️
* Se recomienda que dejes fuentes en ```/var/www/htdocs/sivel2```
* Sigue los mismos pasos para configurar un servidor de desarrollo --excepto
  lanzar
* Crea la base de datos `sivel2gen_pro` con dueño `sipdes`.  Por ejemplo en adJ
  desde el usuario `_postgresql`:
```sh
  createdb -Upostgres -h/var/www/var/run/postgresql -Osipdes sivel2gen_pro
```
* Edita credenciales cifradas con:
```sh
EDITOR=vim bin/rails credentials:edit
```
y 
```sh
RAILS_ENV=production EDITOR=vim bin/rails credentials:edit
```
* Configura la misma base de datos en la sección `production`
  de `config/databases.yml` y ejecuta
```sh
  RAILS_ENV=production bin/rails db:setup 
  RAILS_ENV=production bin/rails db:migrate
  RAILS_ENV=production bin/rails sip:indices
```
* Deja el mismo punto de montaje que usará con el servidor web en `config/application.rb`, `config/routes.rb` y `config/initializers/punto_montaje.rb`
* Configura ruta para anexos y respaldos en `config/initializers/sip.rb` --recomendable en ruta que respalde con periodicidad.
* Configura ruta para la nube (preferible donde quede también respaldada con periodicidad) en `config/application.rb`
* Elige un puerto local no usado (digamos 2009)
* Como servidor web recomendamos nginx, suponiendo que el puerto elegido es 2009, en la sección http agrega:
```
  upstream unicornsivel2 {
	  server 127.0.0.1:2009 fail_timeout=0;
  }
```
* Y agregue también un dominio virtual (digamos `sivel2.pasosdeJesus.org`) con:
```
  server {
    listen 443 ssl;
    ssl_certificate /etc/ssl/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    root /var/www/htdocs/sivel2/;
    server_name sivel2.pasosdeJesus.org
    error_log logs/s2error.log;
    
    location /sivel2 {
      try_files $uri @unicornsivel2;
    }

    location @unicornsivel2 {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $http_host;
      proxy_redirect off;
      proxy_pass http://unicornsivel2;
      error_page 500 502 503 504 /500.html;
      keepalive_timeout 10;
    }
    
    location ^~ /sivel2/assets/ {
      gzip_static on;
      expires max;
      add_header Cache-Control public;
      root /var/www/htdocs/sivel2/public/;
    }

    location ^~ /sivel2/images/ {
      gzip_static on;
      expires max;
      add_header Cache-Control public;
      root /var/www/htdocs/sivel2/public/;
    }
    
    location ^~ /sivel2/packs/ {
      gzip_static on;
      add_header Cache-Control public;
      root /var/www/htdocs/sivel2/public/;
    }
    
  }
```
* Precompila los recursos 
```sh 
RAILS_ENV=production bin/rails assets:precompile
```
* Instala de manera global `unicorn` y el enlace `/usr/local/bin/rails_unicorn`:
```sh
doas gem install unicorn
doas ln -sf /usr
doas ln -sf /usr/local/bin/unicorn_rails31 /usr/local/bin/unicorn_rails
```

* Tras reiniciar nginx, inicia unicorn desde directorio con fuentes con algo como (cambiando la llave, el servidor y el puerto):
```sh 
CONFIG_HOSTS=servidor.miong.org PUERTOUNICORN=2009  DIRAP=/var/www/htdocs/sivel2 USUARIO_AP=$USER SECRET_KEY_BASE=9ff0ee3b245d827293e0ae9f46e684a5232347fecf772e650cc59bb9c7b0d199070c89165f52179a531c5c28f0d3ec1652a16f88a47c28a03600e7db2aab2745 ./bin/u.sh
```
* Para iniciar en cada arranque, por ejemplo en adJ crea /etc/rc.d/sivel2
```sh

servicio="CONFIG_HOSTS=servidor.miong.org PUERTOUNICORN=2009 DIRAP=/var/www/htdocs/sivel2 USUARIO_AP=miusuario SECRET_KEY_BASE=9ff0ee3b245d827293e0ae9f46e684a5232347fecf772e650cc59bb9c7b0d199070c89165f52179a531c5c28f0d3ec1652a16f88a47c28a03600e7db2aab2745 /var/www/htdocs/sivel2/bin/u.sh"


. /etc/rc.d/rc.subr

rc_check() {
        ps axw | grep "[r]uby.*unicorn_rails .*sivel2[/]" > /dev/null
}

rc_stop() {
        p=`ps axw | grep "[r]uby.*unicorn_rails.*master .*sivel2[/]" | sed -e "s/^ *\([0-9]*\) .*/\1/g"`
	kill $p
}

rc_cmd $1
```
  Inicielo con:
```
doas sh /etc/rc.d/sivel2 -d start
```
Y una vez opere bien, incluye ```sivel2``` en la variable ```pkg_scripts``` de ```/etc/rc.conf.local```

### Actualización de servidor de desarrollo :arrows_clockwise:

* Deten el servidor de desarrollo (teclas Control-C)
* Actualiza fuentes: ```git pull```
* Instala nuevas versiones de gemas requeridas: 
``` sh
  bundle install
```
* Aplica cambios a base de datos: ```bin/rails db:migrate```
* Actualiza tablas básicas: ```bin/rails sivel:actbasicas```
* Actualiza índices: ```bin/rails sip:indices```
* Lanza nuevamente el servidor de desarrollo: ```bin/rails s -p 2300 -b 0.0.0.0```

### Actualización de servidor de producción :arrows_clockwise:

Son practicamente los mismos pasos que empleas para actualizar el servidor 
de desarrollo, excepto que `unicorn` se detiene con pkill y se inica
como se describió en Despliegue y que debe preceder cada rake con 
```
RAILS_ENV=production
```

### Respaldos :thumbsup:

En el sitio de producción se recomienda agregar una tarea cron con:

``` sh
cd /var/www/htdocs/sivel2/; RAILS_ENV=production bin/railsp sip:vuelca 
```

## Desarrollo y documentación para desarrolladores :abc:

El desarrollo debe centrarse en los motores que constituyen esta aplicación, 
particularmente ```sivel2_gen```.

La documentación general para desarrolladores que mantenemos está en:
<https://github.com/pasosdeJesus/sip/blob/main/doc/README.md>


## Autores ✒️

Ver [contribuyentes](https://github.com/pasosdeJesus/sivel2/graphs/contributors) y 
<https://github.com/pasosdeJesus/sivel2/blob/main/CREDITOS.md>
