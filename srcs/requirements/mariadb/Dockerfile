# ======================================
# Inception Project - MariaDB Dockerfile
# ======================================

# Use Alpine as base image (lightweight and stable)
FROM alpine:3.19

# Set metadata
LABEL maintainer="mirifern@student.42.fr"
LABEL description="MariaDB Service for Inception Project"

# Update system and install necessary packages
RUN apk update && apk upgrade && \
    apk add --no-cache mariadb mariadb-client

# Create directory for MariaDB data and configuration
RUN mkdir -p /var/lib/mysql /run/mysqld

# Set correct permissions (MariaDB runs as mysql user)
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Copy the custom configuration file
COPY conf/my.cnf /etc/my.cnf

# Copy initialization script
COPY tools/setup.sh /tmp/setup.sh

# Make the script executable
RUN chmod +x /tmp/setup.sh

# Expose MariaDB default port
EXPOSE 3306

# Execute setup script on container start
ENTRYPOINT ["sh", "/tmp/setup.sh"]
