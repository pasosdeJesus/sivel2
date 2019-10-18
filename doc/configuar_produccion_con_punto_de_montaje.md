Supongamos que se necesita un sistema de información para una organización que abreviaremos con laorg, en un URL de la forma misitio.org.co/laorg/sivel2

Clone este repositorio y ubiquelo por ejemplo en /var/www/htdocs/sivel2_laorg

Cree usuario PostgreSQL por ejemplo sivel2laorg

Cree base de datos por ejemplo sivel2_laorg_des, sivel2_laorg_test y sivel2_laorg_prod

Edite los archivos .plantilla

Configure packs

cd public
mkdir laorg
cd laorg
mkdir sivel2
cd sivel2
ln -sf ../../packs
