# ============================
# Inception Project - Makefile
# ============================

# Define and export username from system
export DATA_PATH = /home/$(USER)/data

# The docker-compose file to use.
COMPOSE_FILE = srcs/docker-compose.yml

# Defines the base command for docker-compose operations.
COMPOSE = docker compose -f $(COMPOSE_FILE)

# --- Main Targets ---

# Default target: starts all services.
all: up

# Creates host directories and starts all services in detached mode.
# The --build flag rebuilds images if their Dockerfile has changed.
up: cert
	@echo "Starting all services with Docker Compose..."
	$(COMPOSE) up --build -d

# Stops and removes all containers and networks defined in the compose file.
down:
	@echo "Stopping all services..."
	$(COMPOSE) down

# Full cleanup: stops containers, removes volumes, and deletes all images.
clean:
	@echo "Cleaning the entire environment..."
	$(COMPOSE) down --volumes --rmi all
	@echo "Pruning dangling Docker images..."
	docker image prune -f
	@echo "Pruning dangling Docker volumes..."
	docker volume prune -f
	@echo "Pruning dangling Docker networks..."
	docker network prune -f
	@echo "Deleting host volume data..."
	@sudo rm -rf $(DATA_PATH)/mariadb/*
	@sudo rm -rf $(DATA_PATH)/wordpress/*

# Rebuilds everything from scratch without using any cache.
re: clean cert
	@echo "Rebuilding all services from scratch (no cache)..."
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d

# --- Utility Targets ---

# Generates self-signed SSL certificate if it doesn't exist.
cert:
	@mkdir -p ./srcs/requirements/nginx/tools
	@if [ ! -f ./srcs/requirements/nginx/tools/selfsigned.key ] || [ ! -f ./srcs/requirements/nginx/tools/selfsigned.crt ]; then \
		echo "Generating SSL certificate..."; \
		openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout ./srcs/requirements/nginx/tools/selfsigned.key \
		-out ./srcs/requirements/nginx/tools/selfsigned.crt \
		-subj "/C=ES/ST=Barcelona/L/Barcelona/O=42/OU=Inception/CN=mirifern.42.fr"; \
	fi

# Displays real-time logs for all services.
logs:
	@echo "Showing logs..."
	$(COMPOSE) logs -f

# .PHONY prevents conflicts with files of the same name and improves performance.
.PHONY: all up down clean re cert logs
