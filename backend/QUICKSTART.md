# Quick Start Guide

This guide will help you get the Multi Language Bloc backend up and running in minutes.

## Prerequisites Check

Run these commands to verify you have the required tools:

```bash
# Go version
go version  # Should be 1.23 or higher

# Docker version
docker --version
docker-compose --version

# PostgreSQL (if running locally)
psql --version
```

## 🚀 Getting Started (3 Steps)

### Step 1: Setup Environment

```bash
cd backend
cp .env.example .env
```

Edit the `.env` file and set a secure JWT secret:

```env
JWT_SECRET=your-super-secret-jwt-key-min-32-characters-long
```

### Step 2: Start the Services

**Option A: Using Docker (Recommended)**

```bash
make docker-up
```

**Option B: Local Development**

Terminal 1 - Database:

```bash
# Make sure PostgreSQL is running
createdb multi_lng_bloc
```

Terminal 2 - Auth Service:

```bash
make run-auth
```

Terminal 3 - Gateway:

```bash
make run-gateway
```

### Step 3: Test the API

```bash
./test_api.sh
```

Or test manually:

```bash
# Health check
curl http://localhost:8080/health

# Register a user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe"
  }'
```

## 🎯 Service URLs

- **Gateway API**: http://localhost:8080
- **Auth Service**: http://localhost:8081
- **PostgreSQL**: localhost:5432

## 🧪 Running Your Flutter App

The Flutter app is already configured to use `http://localhost:8080` as the base URL (check `.env` in the project root).

1. **Start the backend** (follow steps above)
2. **Run your Flutter app**:
   ```bash
   flutter run
   ```

## 📝 Common Commands

```bash
# View logs
make docker-logs

# Stop services
make docker-down

# Rebuild services
make docker-rebuild

# Run tests
make test

# Format code
make fmt
```

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Check what's using the port
lsof -i :8080
lsof -i :8081

# Kill the process
kill -9 <PID>
```

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker-compose ps

# View database logs
docker-compose logs postgres

# Restart the database
docker-compose restart postgres
```

### Reset Everything

```bash
make docker-down
make clean
rm -rf backend/.env
# Then start from Step 1
```

## 📚 Next Steps

1. Read the full [README.md](README.md) for detailed API documentation
2. Explore the code structure in the [Project Structure](README.md#-project-structure) section
3. Check out the [API Endpoints](README.md#-api-endpoints) documentation
4. Run the test suite with `make test`

## 🆘 Getting Help

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section above
2. View service logs: `make docker-logs`
3. Verify all prerequisites are installed
4. Ensure ports 8080, 8081, and 5432 are available

---

**You're all set!** 🎉 Your backend is now running and ready to serve your Flutter app.
