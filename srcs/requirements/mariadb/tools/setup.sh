#!/bin/sh
# =========================================
# Inception Project - MariaDB setup script
# ========================================

# Exit if a command exits with a non-zero status
set -e

# Directories
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql
chmod 755 /run/mysqld /var/lib/mysql

# Read secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_USER_PASSWORD=$(cat /run/secrets/db_password)

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First launch detected: initializing database..."
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql > /dev/null

    echo "Starting temporary MariaDB for configuration..."
    # Start MariaDB in the background without networking
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"

    # Wait for MariaDB to be ready
    until mysqladmin ping > /dev/null 2>&1; do
        sleep 1
    done
    echo "Temporary MariaDB server started."

    # Create database and users
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "Database and users created successfully."

    # Stop temporary server
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

# Start MariaDB normally in foreground (PID 1)
echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql

