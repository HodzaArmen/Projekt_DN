.PHONY: help ssl-certs build up down logs ps restart clean test

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

ssl-certs: ## Generate self-signed SSL certificates for local development
	./generate-ssl-certs.sh

build: ssl-certs ## Build Docker images locally
	docker compose build

up: ssl-certs ## Start all services (build if needed)
	docker compose up -d --build

up-prod: ssl-certs ## Start all services using pre-built images
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

down: ## Stop all services
	docker compose down

down-clean: ## Stop all services and remove volumes (DATA LOSS!)
	docker compose down -v

logs: ## Show logs from all services
	docker compose logs -f

ps: ## Show status of all services
	docker compose ps

restart: ## Restart all services
	docker compose restart

test: ## Test that the application is responding
	@echo "Testing HTTP endpoint..."
	@curl -f http://localhost:8080 > /dev/null 2>&1 && echo "✓ HTTP OK" || echo "✗ HTTP Failed"

clean: down-clean ## Clean everything (stop services, remove volumes, remove SSL certs)
	rm -rf nginx/ssl/
	docker system prune -f
