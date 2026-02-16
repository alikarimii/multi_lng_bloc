package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"backend/internal/config"
	"backend/internal/middleware"
	"backend/internal/proxy"
	"backend/internal/router"
)

func main() {
	// Load configuration
	cfg, err := config.LoadGatewayConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Initialize middleware
	authMW := middleware.NewAuthMiddleware(cfg.JWTSecret)
	rateLimiter := middleware.NewRateLimiter(cfg.RateLimit)

	// Initialize service proxy
	serviceProxy := proxy.NewServiceProxy(cfg.AuthServiceURL)

	// Setup router
	handler := router.New(authMW, rateLimiter, serviceProxy)

	// Create server
	server := &http.Server{
		Addr:         fmt.Sprintf(":%s", cfg.Port),
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		log.Printf("🚀 Gateway starting on port %s", cfg.Port)
		log.Printf("📡 Proxying to auth service at %s", cfg.AuthServiceURL)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down gateway...")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Gateway forced to shutdown: %v", err)
	}

	log.Println("✅ Gateway stopped gracefully")
}
