# ========================================
# Inception Project - Nginx Dockerfile
# ========================================

# Use Alpine as base
FROM alpine:3.19

# Labels
LABEL maintainer="your_login@42.fr"

# Install Nginx, OpenSSL, bash and curl
RUN apk update && apk upgrade && \
    apk add --no-cache nginx openssl bash curl

# Create required directories
RUN mkdir -p /var/www/html /etc/nginx/conf.d /etc/ssl /var/log/nginx

# Copy configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy SSL Certificates
COPY tools/selfsigned.crt /etc/ssl/selfsigned.crt
COPY tools/selfsigned.key /etc/ssl/selfsigned.key

# Expose port 443
EXPOSE 443

# Start Nginx in foreground (daemon off)
CMD ["nginx", "-g", "daemon off;"]

