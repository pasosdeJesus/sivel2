# SIVeL 2 [![Estado Construcción](https://api.travis-ci.org/pasosdeJesus/sivel2.svg?branch=master)](https://travis-ci.org/pasosdeJesus/sivel2) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sivel2/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sivel2) [![security](https://hakiri.io/github/pasosdeJesus/sivel2/master.svg)](https://hakiri.io/github/pasosdeJesus/sivel2/master)


Sistema de Información de Violencia Política en Línea versión 2


### Requerimientos
* Ruby version >= 1.9
* PostgreSQL >= 9.3
* Recomendado sobre adJ 5.5 (que incluye todos los componentes mencionados).  
  Las siguientes instrucciones suponen que opera en este ambiente.


### Arquitectura

Es una aplicación que emplea el motor genérico de SIVeL 2 ```sivel2_gen```
Ver https://github.com/pasosdeJesus/sivel2_gen


### Configuración y uso de servidor de desarrollo
* Ubique fuentes por ejemplo en /var/www/htdocs/sivel2/
* Instale gemas requeridas (como Rails 4.1) con:
```sh
  sudo bundle install
  bundle install
```
* Copie y modifique las plantillas:
```sh
  cp config/secrets.yml.plantilla config/secrets.yml
  cp app/views/hogar/_local.html.erb.plantilla app/views/hogar/_local.html.erb
  cp config/database.yml.plantilla config/database.yml
```
* Establezca una ruta para anexos en ```config/initializers/sivel2_gen.rb```.  
  Debe existir y poder ser escrita por el proceso con el que corra el
  servidor de desarrollo.
* Las migraciones del directorio ```db/migrate``` permiten migrar una 
  SIVeL 1.2, actualizando estructura y agregando datos que hagan falta.
  Para actualizar un SIVeL 1.2 saque copia al a base, configure datos de la 
  copia en config/database.yml y ejecute:
```sh
  rake db:migrate
  rake sivel2:indices
```
* Si prefiere comenzar con una base en blanco, cree un superusuario para
  PostgreSQL, configure datos para este en ```config/database.yml``` 
  e inicialice:
```sh
  sudo su - _postgresql
  createuser -h/var/www/tmp -Upostgres -s sivel2des
  exit
  vi config/database.yml
  rake db:setup
  rake sivel2:indices
```
* Lancelo con:
```sh
  rails s
```
* Examine con un navegador el puerto 3000 http://192.168.x.y:3000
* Cuando requiera detener basta que de Control-C o que busque el
  proceso con ruby que corre en el purto 3000 y lo elimine con kill:
```
ps ax | grep "ruby.*3000"
kill 323122
```

### Pruebas

Dado que se hacen pruebas a modelos en sivel2_gen, aquí en sivel2
se implementan algunas pruebas de regresión.
Ejecutelas con:

```sh
RAILS_ENV=test rake db:reset
RAILS_ENV=test rake sivel2:indices
rspec
```

### Desarrollo en codio.com

Opera bien excepto porque no puede usarse capybara-webkit

### Despliegue de prueba en heroku

[![heroku](https://www.herokucdn.com/deploy/button.svg)](http://sivel2.herokuapp.com) http://sivel2.herokuapp.com

Para tener menos de 10000 registros en base de datos se han eliminado ciudades de Colombia y Venezuela. Podrá ver departamentos/estados y municipios.

Los anexos son volatiles, se ubican en /tmp/ en heroku.  El uso de heroku
se detecta en config/initializers/sivel2_gen usando una variable de entorno
--que puede cambiar y debe examinarse con 
	heroku config

### Despliegue en sitio de producción con unicorn:
* Se recomienda que deje fuentes en /var/www/htdocs/sivel2
* Siga los mismos pasos para configurar un servidor de desarrollo --excepto
  lanzar
* Configure la misma base de datos de un SIVeL 1.2 en sección production
  de config/databases.yml y ejecute
```sh
  RAILS_ENV=production rake db:migrate
  RAILS_ENV=production rake sivel:indices
```
* Recomendamos nginx, puede configurar un dominio virtual (digamos
  sivel2.pasosdeJesus.org) con:
```
  server {
    listen 443;
    ssl on;
    ssl_certificate /etc/ssl/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    ssl_session_timeout  5m;
    ssl_protocols  SSLv3 TLSv1;
    ssl_ciphers  HIGH:!aNULL:!MD5;
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
            proxy_pass http://unicorn;
            error_page 500 502 503 504 /500.html;
            client_max_body_size 4G;
            keepalive_timeout 10;
    }

  }
```
* Precompile los recursos 
```sh rake assets:precompile```
* Tras reiniciar nginx, inicie unicorn desde directorio con fuentes con:
```sh ./bin/u.sh```
* Para iniciar en cada arranque, por ejemplo en adJ cree /etc/rc.d/sivel2
```sh
servicio="/var/www/htdocs/sivel2/bin/u.sh"

. /etc/rc.d/rc.subr

rc_cmd $1
```
  E incluya sivel2 en pkg_scripts en /etc/rc.conf.local


### Actualización de servidor de desarrollo

* Detenga el servidor de desarrollo (teclas Control-C)
* Actualice fuentes: ```git pull```
* Instale nuevas versiones de gemas requeridas: 
``` sh
  sudo bundle install
  bundle install
```
* Aplique cambios a base de datos: ```rake db:migrate```
* Actualice tablas básicas: ```rake sivel:actbasicas'''
* Actualice índices: ```rake sivel2:indices```
* Lance nuevamente el servidor de desarrollo: ```rails s```

### Actualización de servidor de producción

Son practicamente los mismos pasos que emplea para actualizar servidor 
de desarrollo, excepto que unicorn se detiene con pkill y se inica
como se describió en Despliegue y que debe preceder cada rake con 
	RAILS_ENV=production

### Convenciones

Las mismas de sivel2_gen
