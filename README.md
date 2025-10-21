# Inception
Configuración completa con Docker Compose en una máquina virtual: contenedores dedicados para NGINX (TLS), WordPress (PHP-FPM) y MariaDB, con volúmenes, red interna y dominio personalizado. Incluye Makefile y siguiendo las mejores prácticas de administración de sistemas.

---

## Pimeros pasos
### Instalar una maquina virtual en nuestro sistema.
Para este proyecto he optdo por instalar con VirtualBox una maquina virtual con una imagen de Lubuntu, puesto que el espacio reservado para este proyecto es bastante limitado y Lubuntu es una versión ligera de Ubuntu que es sudiciente para el desarrollo de este proyecto

### Instalar Docker y Docker Compose
Tras a instalación de todos los recursos necesarios para este proyecto (make, vim, etc...) ????? instalo Docker y Docker Compose. En este proyecto he instalado las versiones:
``` bash
docker --version
  Docker version 28.2.2
docker-compose --version
  docker-compose version 1.29.2
```

### Montar estructura de los directorios
Siguiendo las directices del subject, creo las carpetas y subcarpetas con los archivos necesarios:

<img width="273" height="504" alt="Screenshot from 2025-10-21 19-24-07" src="https://github.com/user-attachments/assets/647df9a5-79ee-4897-9c48-a2840c8d224a" />


## Configuración del Proyecto
Necesitamos crear al menos 3 contenedores: nginx, mariadb y wordpress, para despues agruparlos con Docker Compose.
Todas las configuraciones deben de estar automatizadas para lo cual usaremos el docker-compose.yml y el Makefile para los procesos generales del proyecto y los archivos Dockerfile respectivos de cada contenedor junto con sus archivos necesarios (setup.sh, entrypoint.sh, my.conf, etc...) para cada uno de los servicios.

## MariaDB

## WordPress
Despues de hacer la configuracion basica y comprobar que los contenedores se mantienen levantados y el navegador mediante mi usurio mirifern.42.fr me lleva a la pagina de instalacion de WordPress, debo automatizar esta tarea haciendo que se instale de forma automatica con los datos que he configurado en mis archivos /secrets/ y /srcs/.env.

En esta automatizacion del formulario y de la instalacion podria surgir un problema, que al levantar los contenedores todos a la vez y WordPress depende de MariaDB, podria suceder que el contenedor de MariaDB no se levante por completo antes de proceder a la instalacion de WordPress, por lo que la instalacion podria fallar.

Para evitar esto, utilizare WP_CLI para la automatizacion de WordPress y netcat para esperar al contenedor MariaDB

Anadire en mi Dockerfile de WordPress en esta parte de codigo netcat-openbsd:
```bash
RUN apk update && apk upgrade && \
    apk add --no-cache php php-fpm php-mysqli php-opcache php-json php-session \
                       php-mbstring php-curl php-xml php-gd php-dom shadow curl bash \
                       netcat-openbsd
```
y depues después de la línea  ```bash 'chown -R www-data:www-data /var/www/html' ``` anadire la instalacion de WP-CLI para la automatizacion
```bash
# Install wp-cli (WordPress Command Line)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
```

En el archivo entrypoint.sh cambiare toda la instalacion realizada con curl por la instalacion automatizada mediante WP-CLI de forma que todo el contenido del if [...] fi quedaria esta manera:
```bash
# Download WordPress and install if not present
if [ ! -f /var/www/html/wp-config.php ]; then
        echo "Downloading WordPress..."
        # Clean wp-cli to download it clean
        wp core download --allow-root

        echo "Configuring wp-config.php..."
        wp config create --dbname="$MYSQL_DATABASE" \
                         --dbuser="$MYSQL_USER" \
                         --dbpass="$DB_PASSWORD" \
                         --dbhost="$DB_HOST" \
                         --allow-root

        echo "Installing WordPress..."
        wp core install --url="$DOMAIN_NAME" \
                        --title="$WP_TITLE" \
                        --admin_user="$WP_ADMIN_USER" \
                        --admin_password="$WP_ADMIN_PASSWORD" \
                        --admin_email="$WP_ADMIN_EMAIL" \
                        --skip-email \
                        --allow-root
        echo "Creating WordPress user..."
        wp user create "$WP_USER" "$WP_EMAIL" \
                --role=author \
                --user_pass="$WP_USER_PASSWORD" \
                --allow-root
        echo "WordPress installation complete."

fi
```

Al anadir esto me he encontrado con que ahora la web me arroja 403 Forbidden, consultando los logs he encontrado el siguiente error: ```bash PHP Fatal error:  Uncaught Error: Class "Phar" not found in /usr/local/bin/wp:3```
Esto sucede porque WP-CLI es un Php Archive, es decir, un archivo comprimido con formato (.phar), para que PhP pueda entender y ejecutar este tipo de archivos debemos anadir al Dockerfile la extension php-phar, la pondremos justo despues de la de netcat anadida recientemente. Quedando entonces el comando de instalacion en el Dockerfile de WordPress asi:
```bash
RUN apk update && apk upgrade && \
    apk add --no-cache php-fpm php-mysqli php-opcache php-json php-session \
                       php-mbstring php-curl php-xml php-gd php-dom \
                       php-phar \
                       shadow curl bash netcat-openbsd
```

Al realizar la descompresion de WP-CLI el sistema viene limitado por defecto con 128M de RAM y al compilar tengo este error

asi que en el Dockerfile de WordPress procedo a asignarle mas memoria para evitarlo, anado este comando justo antes de la instalacion de WP-CLI
```bash
# Assign more memory to PHP to avoid wp-cli crashes
RUN echo "memory_limit = 256M" > /etc/php82/conf.d/zz-custom.ini
```
