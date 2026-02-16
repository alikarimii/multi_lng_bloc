.PHONY: help build run test clean docker-up docker-down deps migrate

# Variables
GATEWAY_BINARY=gateway
AUTH_BINARY=auth-service

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

deps: ## Download Go dependencies
	@echo "📦 Downloading dependencies..."
	go mod download
	go mod tidy

build: ## Build both gateway and auth service
	@echo "🔨 Building gateway..."
	go build -o $(GATEWAY_BINARY) cmd/gateway/main.go
	@echo "🔨 Building auth service..."
	go build -o $(AUTH_BINARY) cmd/auth/main.go
	@echo "✅ Build complete!"

build-gateway: ## Build gateway service only
	@echo "🔨 Building gateway..."
	go build -o $(GATEWAY_BINARY) cmd/gateway/main.go

build-auth: ## Build auth service only
	@echo "🔨 Building auth service..."
	go build -o $(AUTH_BINARY) cmd/auth/main.go

run-gateway: ## Run gateway service
	@echo "🚀 Starting gateway..."
	go run cmd/gateway/main.go

run-auth: ## Run auth service
	@echo "🚀 Starting auth service..."
	go run cmd/auth/main.go

test: ## Run tests
	@echo "🧪 Running tests..."
	go test -v -race -coverprofile=coverage.out ./...
	@echo "📊 Coverage report:"
	go tool cover -func=coverage.out

test-coverage: ## Run tests with coverage report
	@echo "🧪 Running tests with coverage..."
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "📊 Coverage report generated: coverage.html"

clean: ## Clean build artifacts
	@echo "🧹 Cleaning..."
	rm -f $(GATEWAY_BINARY) $(AUTH_BINARY)
	rm -f coverage.out coverage.html
	@echo "✅ Clean complete!"

docker-up: ## Start all services with Docker Compose
	@echo "🐳 Starting Docker services..."
	docker-compose up -d
	@echo "✅ Services started!"
	@echo "Gateway: http://localhost:8080"
	@echo "Auth Service: http://localhost:8081"

docker-down: ## Stop all Docker services
	@echo "🐳 Stopping Docker services..."
	docker-compose down

docker-logs: ## Show Docker logs
	docker-compose logs -f

docker-rebuild: ## Rebuild and restart Docker services
	@echo "🐳 Rebuilding Docker services..."
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "✅ Services rebuilt and started!"

db-setup: ## Setup database (requires PostgreSQL running)
	@echo "🗄️  Setting up database..."
	psql -U postgres -c "CREATE DATABASE multi_lng_bloc;" || echo "Database may already exist"

db-drop: ## Drop database
	@echo "🗄️  Dropping database..."
	psql -U postgres -c "DROP DATABASE IF EXISTS multi_lng_bloc;"

lint: ## Run linter
	@echo "🔍 Running linter..."
	golangci-lint run ./...

fmt: ## Format code
	@echo "✨ Formatting code..."
	go fmt ./...
	gofmt -s -w .

vet: ## Run go vet
	@echo "🔍 Running go vet..."
	go vet ./...

check: fmt vet lint ## Run all checks (format, vet, lint)

install-tools: ## Install development tools
	@echo "🔧 Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "✅ Tools installed!"

# Development workflow
dev-setup: deps docker-up ## Setup development environment
	@echo "✅ Development environment ready!"
	@echo "Gateway: http://localhost:8080"
	@echo "Auth Service: http://localhost:8081"

all: deps build test ## Download deps, build, and test
