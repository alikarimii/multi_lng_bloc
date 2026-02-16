# Multi Language Bloc - Backend Service

A microservices-based backend built with Go for the Multi Language Bloc Flutter application. This backend implements a gateway pattern with separate microservices for authentication and user management.

## 🏗️ Architecture

```
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│   API Gateway (Port 8080)       │
│  - Rate Limiting                │
│  - CORS                         │
│  - JWT Validation               │
│  - Request Proxying             │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Auth Service (Port 8081)       │
│  - User Registration            │
│  - Authentication               │
│  - Profile Management           │
│  - Token Management             │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│      PostgreSQL Database        │
│  - Users                        │
│  - Refresh Tokens               │
│  - Usage Statistics             │
└─────────────────────────────────┘
```

## 📁 Project Structure

```
backend/
├── cmd/
│   ├── gateway/          # Gateway service entry point
│   │   └── main.go
│   └── auth/             # Auth service entry point
│       └── main.go
├── internal/
│   ├── config/           # Configuration management
│   │   └── config.go
│   ├── database/         # Database migrations
│   │   └── migrations.go
│   ├── middleware/       # HTTP middleware
│   │   ├── auth.go
│   │   ├── cors.go
│   │   ├── ratelimiter.go
│   │   └── utils.go
│   ├── models/           # Data models
│   │   └── user.go
│   ├── proxy/            # Service proxy
│   │   └── proxy.go
│   ├── repository/       # Data access layer
│   │   ├── user_repository.go
│   │   └── token_repository.go
│   ├── router/           # HTTP routing
│   │   └── router.go
│   └── service/          # Business logic
│       └── auth_service.go
├── services/
│   └── auth/
│       └── handlers/     # HTTP handlers
│           └── auth_handler.go
├── docker-compose.yml    # Docker orchestration
├── Dockerfile.gateway    # Gateway Dockerfile
├── Dockerfile.auth       # Auth service Dockerfile
├── Makefile             # Build automation
├── go.mod               # Go dependencies
├── go.sum               # Dependency checksums
├── .env.example         # Environment template
└── README.md            # This file
```

## 🚀 Quick Start

### Prerequisites

- Go 1.23 or higher
- PostgreSQL 14+ (or use Docker)
- Docker & Docker Compose (optional)

### Option 1: Using Docker (Recommended)

1. **Clone and navigate to the backend directory:**

   ```bash
   cd backend
   ```

2. **Create environment file:**

   ```bash
   cp .env.example .env
   ```

3. **Update the `.env` file with your configuration:**

   ```env
   JWT_SECRET=your-super-secret-jwt-key-change-in-production-min-32-chars
   ```

4. **Start all services:**

   ```bash
   make docker-up
   ```

   This will start:
   - PostgreSQL database on port 5432
   - Auth service on port 8081
   - Gateway on port 8080

5. **Check service health:**
   ```bash
   curl http://localhost:8080/health
   curl http://localhost:8081/health
   ```

### Option 2: Local Development

1. **Install dependencies:**

   ```bash
   make deps
   ```

2. **Setup PostgreSQL database:**

   ```bash
   # Create database
   createdb multi_lng_bloc

   # Or using make
   make db-setup
   ```

3. **Configure environment:**

   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

4. **Run services in separate terminals:**

   Terminal 1 - Auth Service:

   ```bash
   make run-auth
   ```

   Terminal 2 - Gateway:

   ```bash
   make run-gateway
   ```

## 📚 API Endpoints

### Gateway (Port 8080)

All requests should be made to the gateway at `http://localhost:8080`

#### Public Endpoints

**Register**

```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Login**

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Refresh Token**

```bash
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "your-refresh-token"
}
```

**Forgot Password**

```bash
POST /api/v1/auth/forgot-password
Content-Type: application/json

{
  "email": "user@example.com"
}
```

#### Protected Endpoints

All protected endpoints require an `Authorization` header with Bearer token:

**Get Profile**

```bash
GET /api/v1/user/profile
Authorization: Bearer <access_token>
```

**Update Profile**

```bash
PUT /api/v1/user/profile
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Jane Doe"
}
```

**Get Usage Statistics**

```bash
GET /api/v1/user/usage
Authorization: Bearer <access_token>
```

**Delete Account**

```bash
DELETE /api/v1/auth/account
Authorization: Bearer <access_token>
```

## 🧪 Testing

### Run all tests

```bash
make test
```

### Run tests with coverage

```bash
make test-coverage
```

### Example API test with curl

```bash
# Register a new user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Get profile (replace TOKEN with actual token from login)
curl -X GET http://localhost:8080/api/v1/user/profile \
  -H "Authorization: Bearer TOKEN"
```

## 🛠️ Development Commands

```bash
# Build both services
make build

# Build gateway only
make build-gateway

# Build auth service only
make build-auth

# Run tests
make test

# Format code
make fmt

# Run linter
make lint

# Run all checks
make check

# Clean build artifacts
make clean

# Setup development environment
make dev-setup

# View Docker logs
make docker-logs

# Rebuild Docker services
make docker-rebuild

# Stop Docker services
make docker-down
```

## 🔐 Security Features

- **JWT Authentication**: Access tokens with configurable expiry
- **Refresh Tokens**: Long-lived tokens stored in database
- **Password Hashing**: bcrypt with default cost factor
- **Rate Limiting**: IP-based rate limiting (100 req/min default)
- **CORS**: Configurable cross-origin resource sharing
- **SQL Injection Protection**: Parameterized queries

## 🗄️ Database Schema

### Users Table

```sql
users (
  id VARCHAR(36) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### Refresh Tokens Table

```sql
refresh_tokens (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  token VARCHAR(500) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
```

### User Usage Table

```sql
user_usage (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  feature VARCHAR(100) NOT NULL,
  count INTEGER DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(user_id, feature)
)
```

## 📝 Environment Variables

| Variable           | Description                  | Default                 |
| ------------------ | ---------------------------- | ----------------------- |
| `GATEWAY_PORT`     | Gateway service port         | `8080`                  |
| `AUTH_PORT`        | Auth service port            | `8081`                  |
| `JWT_SECRET`       | Secret key for JWT signing   | Required                |
| `AUTH_SERVICE_URL` | URL of auth service          | `http://localhost:8081` |
| `DATABASE_URL`     | PostgreSQL connection string | Required                |

## 🐳 Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild services
docker-compose build --no-cache

# Check service status
docker-compose ps

# Execute command in container
docker-compose exec auth-service sh
docker-compose exec gateway sh
```

## 🚧 Future Enhancements

- [ ] Email service integration for password reset
- [ ] OAuth2 integration (Google, Apple)
- [ ] Two-factor authentication (2FA)
- [ ] File upload service
- [ ] WebSocket support for real-time features
- [ ] Metrics and monitoring (Prometheus/Grafana)
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Distributed tracing (Jaeger)
- [ ] Redis caching layer
- [ ] Message queue integration (RabbitMQ/Kafka)

## 📄 License

This project is part of the Multi Language Bloc Flutter application.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For issues and questions, please open an issue in the repository.

---

Built with ❤️ using Go and PostgreSQL
