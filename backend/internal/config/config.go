package config

import (
	"os"
	"time"

	"github.com/joho/godotenv"
)

type GatewayConfig struct {
	Port           string
	JWTSecret      string
	AuthServiceURL string
	RateLimit      int
}

type AuthConfig struct {
	Port        string
	DatabaseURL string
	JWTSecret   string
	JWTExpiry   time.Duration
}

func LoadGatewayConfig() (*GatewayConfig, error) {
	// Load .env file if exists
	_ = godotenv.Load()

	return &GatewayConfig{
		Port:           getEnv("GATEWAY_PORT", "8080"),
		JWTSecret:      getEnv("JWT_SECRET", "your-super-secret-jwt-key-change-in-production"),
		AuthServiceURL: getEnv("AUTH_SERVICE_URL", "http://localhost:8081"),
		RateLimit:      100, // requests per minute
	}, nil
}

func LoadAuthConfig() (*AuthConfig, error) {
	// Load .env file if exists
	_ = godotenv.Load()

	return &AuthConfig{
		Port:        getEnv("AUTH_PORT", "8081"),
		DatabaseURL: getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/multi_lng_bloc?sslmode=disable"),
		JWTSecret:   getEnv("JWT_SECRET", "your-super-secret-jwt-key-change-in-production"),
		JWTExpiry:   24 * time.Hour,
	}, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
