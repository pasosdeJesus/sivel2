# SIVeL 2 #

## Bienvenido al código fuente de SIVeL ##
Sistema de Información de Violencia Política en Línea versión 2

[![Estado Construcción](https://api.travis-ci.org/pasosdeJesus/sivel2.svg?branch=master)](https://travis-ci.org/pasosdeJesus/sivel2) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) [![security](https://hakiri.io/github/pasosdeJesus/sivel2/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/sivel2.svg)](https://gemnasium.com/pasosdeJesus/sivel2) 

![Logo de sivel2](https://raw.githubusercontent.com/pasosdeJesus/sivel2/master/app/assets/images/logo.jpg)

## Documentación para usuarios finales

<https://docs.google.com/document/d/1xr1vtkfpWdpM_VrEbHacm44NiMPCzAIcRUS1ENoBrQU/edit?usp=sharing>

## Documentación para administradores que despliegan y mantienen en operación la aplicación

### Requisitos 📋

Ver <https://github.com/pasosdeJesus/sip/blob/master/doc/requisitos.md>

### Probar operación en modo de desarrollo 🔧

* Cree un usuario para PostgreSQL como se explica en 
  <https://github.com/pasosdeJesus/sip/blob/master/doc/aplicacion-de-prueba.md>
  (si deja el nombre sipdes se le facilitarán los siguientes pasos)
* Ubique las fuentes en un directorio, por ejemplo en `/var/www/htdocs/sivel2/`
* Asegúrese que las gemas estén instaladas. En el caso de adJ en 
  `/var/www/bundler/ruby/2.6/` siguiendo las instrucciones de 
  <http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby>
  y en el directorio con fuentes asegúrese de tener el archivo `.bundle/config`
  con contenido:
  ```
  ---
  BUNDLE_PATH: "/var/www/bundler"
  BUNDLE_DISABLE_SHARED_GEMS: "true"
  ```
* El archivo `Gemfile` contiene el listado de todas las dependencias a 
  instalar en los distinto ambientes de ejecución. Instale las gemas que 
  se especifican en tal archivo con:
  ```sh
  bundle install
  ```
  (Si quisiera actualizar las dependencias de la aplicación podría ejecutar `bundle update; bundle install`)
  
  Si se interrumpe el proceso por problemas de permisos en instalación de una 
  gema, instálela como en el siguiente ejemplo (cambiando la gema y la versión):
  ```sh
  doas gem install --install-dir /var/www/bundler/ruby/2.6/ bindex -v 0.7.0
  ```
* Copie y de requerirlo modifique las plantillas:
```sh
  find . -name "*plantilla"
  for i in `find . -name "*plantilla"`; do 
    n=`echo $i | sed -e "s/.plantilla//g"`; 
    if (test ! -e $n) then { 
      echo $n; 
      cp $i $n; 
    } fi; 
  done
```
  Estas plantillas dejan la aplicación en el URL /sivel2/ (tendría que 
  modificarlas si prefiere una raíz de URL diferente, ver
  <https://github.com/pasosdeJesus/sip/blob/master/doc/punto-de-montaje.md> )

  Lo mínimo que debe modificar es establecer usuario PostgreSQL, clave y 
  bases de datos (desarrollo, pruebas y producción) que configuró en 
  PostgreSQL en `config/database.yml`.

* Las migraciones del directorio `db/migrate` de ```sivel2_gen``` permiten 
  migrar una SIVeL 1.2, actualizando estructura y agregando datos que hagan 
  falta.
  Para actualizar un SIVeL 1.2 saque copia a la base, configure datos de la 
  copia en `config/database.yml` y ejecute:
  ```sh
  bin/rails db:migrate
  bin/rails sip:indices
  ```
  Si va a empezar con una base nueva ```sivel2gen_des``` como usuario de 
  PostgreSQL sipdes:
  ```sh
  createdb -U sipdes -h /var/www/var/run/postgresql/ sivel2gen_des
  ```
  y desde el directorio de la aplicación:  
  ```sh
  bin/rails db:setup
  bin/rails db:migrate
  bin/rails sip:indices
  ```
* Si no lo ha hecho instale yarn para manejar paquetes javascript:
  ```sh
  doas pkg_add bash
  ftp -o- https://yarnpkg.com/install.sh | bash
  . ~/.profile
  ```
* Instale librerías Javascript requeridas al lado del cliente con:
```sh
  CXX=c++ yarn install
  ```
* Lance la aplicación en modo de desarrollo. En el siguiente ejemplo el 
  parametro `-p` indica el puerto por el cual escuchará la aplicación 
  y el parámetro `-b` indica la dirección IP como **0.0.0.0**
 para que se pueda acceder desde cualquiera de las IPs configuradas en las interfaces de red:
```sh
  bin/rails s -p 2300 -b 0.0.0.0
```
* Examine con un navegador que tenga habilitadas las galletas (cookies) en el 
  puerto 2300: `http://127.0.0.1:2300`.  (Por eso si usa el 
  navegador `w3m` añada la opción `-cookie`) 
* Cuando requiera detener basta que de Control-C o que busque el
  proceso con ruby que corre en el puerto 3000 y lo elimine con `kill`:
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
```sivel2_gen```, en ```sivel2``` sólo se implementan algunas pruebas 
de integración con `capybara` y `poltergeist` (ver carpeta
`test/` y documentación de como desarrollarlas en <https://github.com/pasosdeJesus/sip/blob/master/doc/pruebas-con-minitest.md>), 
así como pruebas al sistema con sideex (ver carpeta `test/sideex` y documentación 
de como hacerlas en <https://github.com/pasosdeJesus/sip/blob/master/doc/pruebas-al-sistema-con-sideex.md>
).  

Si ya configuró el servidor de desarrollo como se explicó antes y logró ver
la aplicación corriendo puede ejecutar las pruebas de integración con:

```sh
RAILS_ENV=test bin/rails db:reset
RAILS_ENV=test bin/rails sip:indices
bin/rails test
```

Y para ejecutar las pruebas del sistema, ejecute la aplicación en modo de desarrollo
y desde el navegador en el que la visualiza, instale la extensión sideex (http://www.sideex.org/), 
cargue las suits de prueba de la carpeta `test/sideex` y corralas.  La mayoría de pruebas
debería pasar (en ocasiones algunas no pasan por demoras en la aplicación para servir
páginas o responder AJAX, pero si ejecuta varias veces eventualmente mejorando servidor,
cliente o conexión entre ambos, deberían pasar).


### Despliegue en sitio de producción con unicorn ⌨️
* Se recomienda que deje fuentes en ```/var/www/htdocs/sivel2```
* Siga los mismos pasos para configurar un servidor de desarrollo --excepto
  lanzar
* Cree la base de datos `sivel2gen_pro` con dueño `sipdes`.  Por ejemplo en adJ
  desde el usuario `_postgresql`:
```sh
  createdb -Upostgres -h/var/www/var/run/postgresql -Osipdes sivel2gen_pro
```
* Edite credenciales cifradas con:
```sh
EDITOR=vim bin/rails credentials:edit
```
y 
```sh
RAILS_ENV=production EDITOR=vim bin/rails credentials:edit
```
* Configure la misma base de datos de un SIVeL 1.2 en la sección `production`
  de `config/databases.yml` y ejecute
```sh
  RAILS_ENV=production bin/rails db:setup 
  RAILS_ENV=production bin/rails db:migrate
  RAILS_ENV=production bin/rails sip:indices
```
* Deje el mismo punto de montaje que usará con el servidor web en `config/application.rb`, `config/routes.rb` y `config/initializers/punto_montaje.rb`
* Configure ruta para anexos y respaldos en `config/initializers/sip.rb` --recomendable en ruta que respalde con periodicidad.
* Configure ruta para la nube (preferible donde quede también respaldada con periodicidad) en `config/application.rb`
* Elija un puerto no usado (digamos 2009) y configure tanto unicorn de la aplicación como el servidor web para usarlo. Puede configurar unicorn de la aplicación editando `config/unicorn.conf.minimal.rb`:
```
listen 2009
```
* Como servidor web recomendamos nginx, suponiendo que el puerto elegido es 2009, en la sección http agregue:
```
  upstream unicorns2 {
	  server 127.0.0.1:2009 fail_timeout=0;
  }
```
* Y agregue también un dominio virtual (digamos `sivel2.pasosdeJesus.org`) con:
```
  server {
    listen 443;
    ssl on;
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

    
  }
```
* Precompile los recursos 
```sh 
bin/rails assets:precompile
```
* Tras reiniciar nginx, inicie unicorn desde directorio con fuentes con algo como (cambiando la llave):
```sh 
DIRAP=/var/www/htdocs/sivel2 USUARIO_AP=$USER SECRET_KEY_BASE=9ff0ee3b245d827293e0ae9f46e684a5232347fecf772e650cc59bb9c7b0d199070c89165f52179a531c5c28f0d3ec1652a16f88a47c28a03600e7db2aab2745 ./bin/u.sh
```
* Para iniciar en cada arranque, por ejemplo en adJ cree /etc/rc.d/sivel2
```sh

servicio="DIRAP=/var/www/htdocs/sivel2 RAILS_RELATIVE_URL_ROOT=/ USUARIO_AP=$USER SECRET_KEY_BASE=9ff0ee3b245d827293e0ae9f46e684a5232347fecf772e650cc59bb9c7b0d199070c89165f52179a531c5c28f0d3ec1652a16f88a47c28a03600e7db2aab2745 /var/www/htdocs/sivel2/bin/u.sh"

. /etc/rc.d/rc.subr

rc_check() {
        ps axw | grep "[r]uby.*unicorn_rails .*sivel2" > /dev/null
}

rc_stop() {
        p=`ps axw | grep "[r]uby.*unicorn_rails.*master .*sivel2" | sed -e "s/^ *\([0-9]*\) .*/\1/g"`
	kill $p
}

rc_cmd $1
```
  E incluya ```sivel2``` en la variable ```pkg_scripts``` de ```/etc/rc.conf.local```

### Actualización de servidor de desarrollo :arrows_clockwise:

* Detenga el servidor de desarrollo (teclas Control-C)
* Actualice fuentes: ```git pull```
* Instale nuevas versiones de gemas requeridas: 
``` sh
  bundle install
```
* Aplique cambios a base de datos: ```bin/rails db:migrate```
* Actualice tablas básicas: ```bin/rails sivel:actbasicas```
* Actualice índices: ```bin/rails sip:indices```
* Lance nuevamente el servidor de desarrollo: ```bin/rails s -p 2300 -b 0.0.0.0```

### Actualización de servidor de producción :arrows_clockwise:

Son practicamente los mismos pasos que emplea para actualizar servidor 
de desarrollo, excepto que `unicorn` se detiene con pkill y se inica
como se describió en Despliegue y que debe preceder cada rake con 
```
RAILS_ENV=production
```

### Respaldos :thumbsup:

En el sitio de producción se recomienda agregar una tarea cron con:

``` sh
cd /var/www/htdocs/sivel2/; RAILS_ENV=production bin/rake sivel2:vuelca 
```

## Desarrollo y documentación para desarrolladores :abc:

El desarrollo debe centrarse en los motores que constituyen esta aplicación, 
particularmente ```sivel2_gen```.

La documentación general para desarrolladores que mantenemos está en:
<https://github.com/pasosdeJesus/sip/blob/master/doc/README.md>


## Autores ✒️

Ver [contribuyentes](https://github.com/pasosdeJesus/sivel2/graphs/contributors) y 
<https://github.com/pasosdeJesus/sivel2/blob/master/CREDITOS.md>
