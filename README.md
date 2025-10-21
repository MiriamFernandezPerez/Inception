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
<img width="544" height="1015" alt="Screenshot from 2025-10-21 19-22-25" src="https://github.com/user-attachments/assets/11aefd31-52f7-4d2c-b0f7-edf7bb3c980d" />


