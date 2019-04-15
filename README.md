# SIVeL 2 #

## Bienvenido al código fuente de SIVeL ##
Sistema de Información de Violencia Política en Línea versión 2

[![Estado Construcción](https://api.travis-ci.org/pasosdeJesus/sivel2.svg?branch=master)](https://travis-ci.org/pasosdeJesus/sivel2) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) [![security](https://hakiri.io/github/pasosdeJesus/sivel2/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/sivel2.svg)](https://gemnasium.com/pasosdeJesus/sivel2) 

![Logo de sivel2](https://raw.githubusercontent.com/pasosdeJesus/sivel2/master/app/assets/images/logo.jpg)


### Requerimientos 📋
* Ruby version >= 2.6.2
* Ruby on Rails 5.2.x 
* PostgreSQL >= 11.2 con extensión ```unaccent``` disponible
* ```node.js``` y ```coffescript``` instalado globalmente (i.e  ```npm install -g coffee-script```)
* Recomendado sobre adJ 6.4 (que incluye todos los componentes mencionados)
  usando ```bundler``` con ```doas```, ver
  <http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby>.
* El usuario que utilice la aplicación debe tener permiso de usar al menos 1024M en RAM y para abrir al menos 2048 archivos.  En adJ asegurate de poner un valor alto al máximo de archivos que el kernel pueden abrir simultanemanete en la variable de configuración ```kern.maxfiles``` por ejemplo 20000 en ```/etc/sysctl.conf``` y en la clase del usuario que inicia la aplicación (en ```/etc/login.conf```) que al menos diga ```:datasize-cur=1024M:``` y ```:openfiles-cur=2048:```

Estas instrucciones suponen que operas en este ambiente, puedes ver más sobre
la instalación de Ruby on Rails en adJ en
<http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby>


### Arquitectura :small_red_triangle:
En Ruby los motores pueden considerarse aplicaciones en miniatura que proporcionan funcionalidad a sus aplicaciones host. Una aplicación de Rails es en realidad solo un motor "supercargado", con la clase Rails :: Application heredando gran parte de su comportamiento de Rails :: Engine.Esta aplicación emplea 3 motores genéricos:
>1. Desarrollo personalizado: 
[sivel2_gen](https://github.com/pasosdeJesus/sivel2_gen)
>
>2. Nube:
[heb412_gen](https://github.com/pasosdeJesus/heb412_gen)
>
>3. Actualización:
[sip](https://github.com/pasosdeJesus/sip)


### Configuración y uso de servidor de desarrollo 🔧

Cree un usuario para PostgreSQL como se explica en 
<https://github.com/pasosdeJesus/sip/wiki/Aplicaci%C3%B3n-de-prueba>
(si deja el nombre sipdes se le facilitarán los siguientes pasos)

* Ubique fuentes por ejemplo en ```/var/www/htdocs/sivel2/```
* Asegurese que las gemas esten instaladas en ```/var/www/bundler/ruby/2.6/``` siguiendo instrucciones de <http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby>
* El archivo ```/var/www/htdocs/sivel2/Gemfile```contiene el listado de todas las dependencias a instalar en los distinto ambientes de ejecucion. Instale las gemas que se especifican en tal archivocon:
```shell=
  cd /var/www/htdocs/sivel2/
  bundle install
```

si se interrumpe por problemas de permisos en instalación de una gema, instalela como en el siguiente ejemplo (cambiando la gema y la versión):
```sh
doas gem install --install-dir /var/www/bundler/ruby/2.6/ bindex -v 0.7.0
```
y continúe con `bundle install`
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
  Estas plantillas dejan la aplicación en el URL /sivel2/ (tendría que modificarlas
  si prefiere una raiz de URL diferente, ver sección 'Punto de montaje' de 
  https://github.com/pasosdeJesus/sip/wiki/Personalizaci%C3%B3n-de-rutas,-controladores-y-vistas ).
  Asegurese de establecer usuario y base de datos que configuró en PostgreSQL en config/database.yml.
* Las  migraciones del directorio ```db/migrate``` de ```sivel2_gen``` permiten 
  migrar una SIVeL 1.2, actualizando estructura y agregando datos que hagan 
  falta.
  Para actualizar un SIVeL 1.2 saque copia a la base, configure datos de la 
  copia en ```config/database.yml``` y ejecute:
```sh
  bin/rails db:migrate
  bin/rails sip:indices
```
  Si va a empezar con una base nueva sivel2gen_des como usuario de PostgreSQL sipdes:
```sh
  createdb -U sipdes -h /var/www/var/run/postgresql/ sivel2gen_des
```
  y desde el directorio de la aplicación:  
```sh
  bin/rails db:setup
  bin/rails sip:indices
```
  
* Lance la aplicación en modo de desarrollo el parametro -p que indica el puerto por el cual escuchara la aplicacion y el parametro -b como **0.0.0.0** para que se pueda acceder desde cualquier ip externa y no se limite a localhost:
```shell
  bin/rails s -p 3000 -b 0.0.0.0
```
* Examine con un navegador que tenga habilitadas las galletas (cookies) en el 
  puerto 3000: ```http://127.0.0.1:3000```.  Por eso si usa el navegador ```w3m``` 
  añada la opción ```-cookie``` 
* Cuando requiera detener basta que de Control-C o que busque el
  proceso con ruby que corre en el puerto 3000 y lo elimine con ```kill```:
```sh
ps ax | grep "ruby.*3000"
kill 323122
```
* En este modo es recomendable borrar recursos precompilados 
```sh
rm -rf public/assets/*
```

### Pruebas ⚙️

Dado que se hacen pruebas a modelos, rutas, controladores y vistas en 
```sivel2_gen```, en ```sivel2``` sólo se implementan algunas pruebas 
de regresión con capybara-webkit.  Si ya configuró el servidor de desarrollo
como se explicó antes, basta ejecutarlas con:

```sh
RAILS_ENV=test bundle exec rake db:reset
RAILS_ENV=test bundle exec rake sip:indices
bundle exec rails test
```

### Desarrollo en codio.com ⌨️

Opera bien excepto por la lentitud (aunque es más rápido que otros sitios
de desarrollo) y porque no puede usarse ```capybara-webkit```. 

### Despliegue de prueba en Heroku ⌨️

[![heroku](https://www.herokucdn.com/deploy/button.svg)](http://sivel2.herokuapp.com) 

Para tener menos de 10000 registros en base de datos se han eliminado ciudades 
de Colombia y Venezuela. Podrá ver departamentos/estados y municipios.

Los anexos son volatiles pues tuvieron que ubicarse en ```/tmp/``` (que se 
borra con periodicidad).

En tiempo de ejecución el uso de heroku se detecta en 
```config/initializers/sivel2_gen``` usando una variable de entorno 
--que cambia de un despliegue a otro y que debe examinarse con 
```sh
	heroku config
```
Para que heroku solo instale las gemas de producción:
```sh
	heroku config:set BUNDLE_WITHOUT="development:test"
```

Otras labores tipicas son:
* Para iniciar interfaz Postgresql: ```heroku pg:psql```
* Para ejecutar migraciones faltantes: ```heroku run rake db:migrate```
* Para examinar configuración ```heroku config``` que entre otras mostrará URL 
  y nombre de la base de datos.
* Heroku usa base de datos de manera diferente, para volver a inicializar 
  base de datos (cuyo nombre se ve con ```heroku config```):  
  ```heroku pg:reset nombrebase```

### Medición de tiempos :hourglass_flowing_sand:

En el archivo TIEMPO.md se han consignado algunas mediciones de tiempo de 
respuesta medidos con el inspector del navegador Chrome (una vez en la página 
de ingreso a SIVeL, botón derecho Inspeccionar Elemento, pestaña Network). 
En ese archivo se ha consignado el tiempo de cada prueba junto con el servidor 
y el cliente usado.


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
y con
```sh
RAILS_ENV=production EDITOR=vim bin/rails credentials:edit
```
* Configure la misma base de datos de un SIVeL 1.2 en sección `production`
  de `config/databases.yml` y ejecute
```sh
  RAILS_ENV=production bin/rails db:setup 
  RAILS_ENV=production bin/rails db:migrate
  RAILS_ENV=production bin/rails sip:indices
```
* Como servidor web recomendamos nginx, en la sección http agregue:
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

    location ^~ /assets/ {
        gzip_static on;
        expires max;
        add_header Cache-Control public;
        root /var/www/htdocs/sivel2/public/;
    }

    try_files $uri/index.html $uri @unicorn;
    location @unicorn {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_pass http://unicorns2;
            error_page 500 502 503 504 /500.html;
            client_max_body_size 4G;
            keepalive_timeout 10;
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
* Aplique cambios a base de datos: ```rake db:migrate```
* Actualice tablas básicas: ```rake sivel:actbasicas```
* Actualice índices: ```rake sip:indices```
* Lance nuevamente el servidor de desarrollo: ```rails s```

### Actualización de servidor de producción :arrows_clockwise:

Son practicamente los mismos pasos que emplea para actualizar servidor 
de desarrollo, excepto que unicorn se detiene con pkill y se inica
como se describió en Despliegue y que debe preceder cada rake con 
```
RAILS_ENV=production
```

### Respaldos :thumbsup:

En el sitio de producción se recomienda agregar una tarea cron con:

``` sh
cd /var/www/htdocs/sivel2/; RAILS_ENV=production bin/rake sivel2:vuelca 
```

### Convenciones :abc:

Las mismas de ```sip```.  Ver <https://github.com/pasosdeJesus/sip/wiki/Convenciones>

## Autores ✒️

Ver [contribuyentes](https://github.com/pasosdeJesus/sivel2/graphs/contributors) y 
<https://github.com/pasosdeJesus/sivel2/blob/master/CREDITOS.md>
