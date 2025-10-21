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
<img width="546" height="1008" alt="Screenshot from 2025-10-21 19-24-07" src="https://github.com/user-attachments/assets/647df9a5-79ee-4897-9c48-a2840c8d224a" />


## Configuración del Proyecto
Necesitamos crear al menos 3 contenedores: nginx, mariadb y wordpress, para despues agruparlos con Docker Compose.
Todas las configuraciones deben de estar automatizadas para lo cual usaremos el docker-compose.yml y el Makefile para los procesos generales del proyecto y los archivos Dockerfile respectivos de cada contenedor junto con sus archivos necesarios (setup.sh, entrypoint.sh, my.conf, etc...) para cada uno de los servicios.

MariaDB

