#!/bin/bash

# Este script pepara un codspace/action de github con locale, paquetes 
# (e.g PostgreSQL, # PostGIS), base de datos y variables de ambiente 
# para correr la aplicación de prueba y/o las pruebas

# pdftoppm en poppler-utils
echo "Ejecutando ambiente_github.sh"
sudo apt update
sudo apt install -y poppler-utils
sudo locale-gen es_CO.UTF-8 && sudo update-locale

# Instala PostgreSQL 17 y PostGIS 3 y las librerías requeridas
if (test ! -f /etc/postgresql/17/main/pg_hba.conf) then {
	wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/postgresql.asc
	echo 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/postgresql.asc] https://apt.postgresql.org/pub/repos/apt/ noble-pgdg main' | sudo tee /etc/apt/sources.list.d/pgdg.list
	sudo apt update
	sudo apt install -y postgresql-17 postgresql-client-17
	sudo apt install -y postgis postgresql-17-postgis-3
	sudo pg_createcluster 17 main --start
	sudo sed -i "s|local.*all.*all.*peer|local all all md5|g" /etc/postgresql/17/main/pg_hba.conf
	sudo cat /etc/postgresql/17/main/pg_hba.conf
} fi;
echo "Reiniciando postgresql"
sudo service postgresql restart
echo "PostgreSQL reiniciado"

psql --version

# Crea usuario y base de datos como usuario postgres
echo "Creando usuario"
sudo su - postgres -c "createuser -s rails"
echo "Cambiando clave"
sudo su - postgres -c "psql -c \"ALTER USER rails WITH PASSWORD 'password';\""
echo "Facilitando uso"
echo "*:*:*:rails:password" >> ~/.pgpass
chmod 0600 ~/.pgpass
echo ":::: cat ~/.pgpass::::"   
cat ~/.pgpass     
echo "Creando base"
sudo su - postgres -c "createdb -O rails rails_test"
echo "Creada"

# Configura el ambiente
cd "$(dirname "$0")/.." || exit 1
if (test -d test/dummy) then {
  cd test/dummy
} fi;
pwd
cp .env.github .env
echo "::::.env antes de modificar es::::"
cat .env

# Modifica el archivo .env con rutas locales y configuraciones
DIRAP=$(pwd)
sed -i "s|export DIRAP=.*|export DIRAP=${DIRAP}/|g" .env
#sed -i "s|export BD_SERVIDOR=.*|export BD_SERVIDOR=localhost|g" .env
echo "export RAILS_ENV=test" >> .env

echo "::::.env tras modificacion es es::::"
cat .env

# Ejecuta el archivo con variables de ambiente
source .env

echo "¡Ambiente configurado con exito!"
echo "Directorio de la aplicaciónde datos: $DIRAP"
echo "Base de datos: $BD_PRUEBA"
echo "Usuario: $BD_USUARIO"
echo "host: $BD_SERVIDOR"
echo "Localización del archivo de ambiente: $DIRAP/.env"

# bundle
# RAILS_ENV=test bin/rails dbconsole

