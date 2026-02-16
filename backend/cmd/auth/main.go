package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"backend/internal/config"
	"backend/internal/database"
	"backend/internal/repository"
	"backend/internal/service"
	"backend/services/auth/handlers"

	_ "github.com/lib/pq"
)

func main() {
	// Load configuration
	cfg, err := config.LoadAuthConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Initialize database
	db, err := sql.Open("postgres", cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Test database connection
	if err := db.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}
	log.Println("✅ Database connected successfully")

	// Run migrations
	if err := database.RunMigrations(db); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}
	log.Println("✅ Database migrations completed")

	// Initialize repositories
	userRepo := repository.NewUserRepository(db)
	tokenRepo := repository.NewTokenRepository(db)

	// Initialize services
	authService := service.NewAuthService(userRepo, tokenRepo, cfg.JWTSecret, cfg.JWTExpiry)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)

	// Setup routes
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok","service":"auth"}`))
	})

	// Auth endpoints
	mux.HandleFunc("POST /api/v1/auth/register", authHandler.Register)
	mux.HandleFunc("POST /api/v1/auth/login", authHandler.Login)
	mux.HandleFunc("POST /api/v1/auth/refresh", authHandler.RefreshToken)
	mux.HandleFunc("POST /api/v1/auth/forgot-password", authHandler.ForgotPassword)
	mux.HandleFunc("DELETE /api/v1/auth/account", authHandler.DeleteAccount)

	// User endpoints
	mux.HandleFunc("GET /api/v1/user/profile", authHandler.GetProfile)
	mux.HandleFunc("PUT /api/v1/user/profile", authHandler.UpdateProfile)
	mux.HandleFunc("GET /api/v1/user/usage", authHandler.GetUsage)
	mux.HandleFunc("GET /api/v1/users", authHandler.ListUsers)
	mux.HandleFunc("GET /api/v1/users/{id}", authHandler.GetUserByID)

	// Create HTTP server
	server := &http.Server{
		Addr:         fmt.Sprintf(":%s", cfg.Port),
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		log.Printf("🚀 Auth service starting on port %s", cfg.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down auth service...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	db.Close()
	log.Println("✅ Auth service stopped gracefully")
}
