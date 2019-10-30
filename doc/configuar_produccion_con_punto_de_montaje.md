Supongamos que se necesita un sistema de información para una organización que abreviaremos con laorg, en un URL de la forma misitio.org.co/laorg/sivel2

Clone este repositorio y ubiquelo por ejemplo en /var/www/htdocs/sivel2_laorg

Cree usuario PostgreSQL por ejemplo sivel2laorg

Cree base de datos por ejemplo sivel2_laorg_des, sivel2_laorg_test y sivel2_laorg_prod

Edite los archivos .plantilla

Inicialice base de datos

Configure packs

cd public
mkdir laorg
cd laorg
mkdir sivel2
cd sivel2
ln -sf ../../packs

Configure en nginx: puerto donde correra unicorn, rutas

upstream unicornsivel2fian {
  server 127.0.0.1:2039 fail_timeout=0;
}


# Soluciones a problemas comunes

Si la página inicial se ve así:
[https://github.com/pasosdeJesus/sivel2/raw/master/doc/imagenes/inicio-sin-assets.png]

Seguramente el navegador no logra cargar los recursos (assets), revise:
* Que en la configuración del punto de montaje se use el directorio assets, i.e en config/initializers/punto_montaje.rb diga:
```ruby                                                                              
Sivel2::Application.config.relative_url_root = '/csofb/sivel2'
Sivel2::Application.config.assets.prefix = '/csofb/sivel2/assets'
```
* Que la configuración de nginx tenga ruta para los recursos:
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
