#!/bin/sh
# ======================
# WordPress Setup Script
# ======================

# Exit is a command exist with a non-zero status
set -e

# Variables from Docker
DB_NAME=${MYSQL_DATABASE:-wp_database}
DB_USER=${MYSQL_USER:-wp_user}
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
DB_HOST="mariadb:3306"

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

# Add permission to manage plugins and files
chown -R www-data:www-data /var/www/html

# Fix PHP-FPM listen address (allow external connections)
sed -i "s|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|" /etc/php*/php-fpm.d/www.conf

# Run PHP-FPM in foreground
echo "Init PHP-FPM..."
exec php-fpm82 -F
