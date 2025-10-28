# ========================================
# Inception Project - WordPress Dockerfile
# ========================================

FROM alpine:3.19

LABEL maintainer="mirifern@student.fr"
LABEL description="WordPress Service for Inception Project"

# Install required packages.
RUN apk update && apk upgrade && \
    apk add --no-cache php-fpm php-mysqli php-opcache php-json php-session \
                       php-mbstring php-curl php-xml php-gd php-dom \
                       php-phar \
                       shadow curl bash

# Assign more memory to PHP from 128M to 256m to avoid wp-cli crashes
RUN echo "memory_limit = 256M" > /etc/php82/conf.d/zz-custom.ini

# [ULTIMATE ROBUST SOLUTION]
# The php-fpm package creates the 'www-data' GROUP, but not the USER.
# This logic handles that case by checking for the group and user separately.
RUN addgroup -S www-data -g 82 || echo "Group www-data already exists" && \
	adduser -S www-data -u 82 -G www-data || echo "User www-data already exists"

# Create WordPress directory and set permissions for the 'www-data' user.
# This step will now always succeed because the command above guarantees the user exists.
RUN mkdir -p /var/www/html && \
	chown -R www-data:www-data /var/www/html

# Install WP-CLI (WordPress Command Line)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Set working directory
WORKDIR /var/www/html

# Copy entrypoint script
COPY tools/entrypoint.sh /tmp/entrypoint.sh
RUN chmod +x /tmp/entrypoint.sh

# Expose PHP-FPM port
EXPOSE 9000

# Entrypoint
ENTRYPOINT ["sh", "/tmp/entrypoint.sh"]
