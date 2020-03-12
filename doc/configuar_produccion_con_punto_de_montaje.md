# Instrucciones para poner un sistema en produccin en un punto de montaje que no es /

Las instrucciones para poner un sistema en produccin en / pueden verse en el archivo README.md de las fuentes de SIVeL.

Estas instrucciones suponen que ya conoce las primeras y que necesita un sistema de información para una organización que abreviaremos con `laorg`, en un URL de la forma misitio.org.co/laorg/sivel2

* Clone este repositorio y ubiquelo por ejemplo en `/var/www/htdocs/sivel2_laorg`
* Cree usuario PostgreSQL por ejemplo `sivel2laorg`
* Cree base de datos por ejemplo `sivel2_laorg_des`, `sivel2_laorg_test` y `sivel2_laorg_prod`
* Copie renombrando y edite los archivos .plantilla
* Inicialice base de datos
* Configure packs
        cd public
        mkdir laorg
        cd laorg
        mkdir sivel2
        cd sivel2
        ln -sf ../../packs

* Configure en nginx: puerto donde correra unicorn, rutas

upstream unicornsivel2fian {
  server 127.0.0.1:2039 fail_timeout=0;
}


## Soluciones a problemas comunes

### Págia inicial sin recursos gráficos

![Pantallazo de inicio sin recursos](https://github.com/pasosdeJesus/sivel2/raw/master/doc/imagenes/inicio-sin-assets.png)
O al inspeccionar fuentes y revisar consola ve mensajes del estilo:
```
GET https://rbd.nocheyniebla.org:15443/csofb/sivel2/application-3f56911d83c1e4aab6ce1f08fbd92f8d83166c1f765cee5dd29f1ae0ebad9219.js net::ERR_ABORTED 404 (Not Found)
```

Seguramente el navegador no logra cargar los recursos (assets), revise:
* Que en la configuración del punto de montaje se use el directorio assets, i.e en `config/initializers/punto_montaje.rb` diga:
```ruby                                                                              
Sivel2::Application.config.relative_url_root = '/csofb/sivel2'
Sivel2::Application.config.assets.prefix = '/csofb/sivel2/assets'
```
* Que la configuración de nginx tenga ruta para los recursos, es decir en `/etc/nginx/nginx.conf` en la sección para el sitio que incluya:
```nginx.conf
location ^~ /csofb/sivel2/assets/ { 
        gzip_static on;                                                  
        expires max;
        add_header Cache-Control public;
        root /var/www/htdocs/sivel2_csofb/public/;
}
        
location ^~ /csofb/sivel2/images/ {  
        gzip_static on; 
        expires max;
        add_header Cache-Control public;
        root /var/www/htdocs/sivel2_csofb/public/;  
}
```

### Mapa y otras experiencias interactivas no operan

Por ejemplo el mapa se ve así:
![Mapa sin webpack](https://github.com/pasosdeJesus/sivel2/raw/master/doc/imagenes/sivel2-sin-js-webpack.png)

Es posible que no se estén cargando los recursos Javascript preparados con webpack, asegurese de que exista el enlace packs:
```
cd public/laorg/sivel2
ln -s ../../packs .
```


### No permite subir anexos grandes

