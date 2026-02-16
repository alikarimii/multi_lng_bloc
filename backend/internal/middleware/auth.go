package middleware

import (
	"context"
	"fmt"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

type contextKey string

const UserIDKey contextKey = "userID"

type AuthMiddleware struct {
	jwtSecret string
}

func NewAuthMiddleware(jwtSecret string) *AuthMiddleware {
	return &AuthMiddleware{
		jwtSecret: jwtSecret,
	}
}

func (m *AuthMiddleware) RequireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			respondJSON(w, http.StatusUnauthorized, map[string]string{
				"error": "Missing authorization header",
			})
			return
		}

		// Extract token from "Bearer <token>"
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			respondJSON(w, http.StatusUnauthorized, map[string]string{
				"error": "Invalid authorization header format",
			})
			return
		}

		tokenString := parts[1]

		// Parse and validate token
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(m.jwtSecret), nil
		})

		if err != nil || !token.Valid {
			respondJSON(w, http.StatusUnauthorized, map[string]string{
				"error": "Invalid or expired token",
			})
			return
		}

		// Extract user ID from claims
		if claims, ok := token.Claims.(jwt.MapClaims); ok {
			if userID, ok := claims["user_id"].(string); ok {
				// Add user ID to context
				ctx := context.WithValue(r.Context(), UserIDKey, userID)
				// Add user ID to header for downstream services
				r.Header.Set("X-User-ID", userID)
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}
		}

		respondJSON(w, http.StatusUnauthorized, map[string]string{
			"error": "Invalid token claims",
		})
	})
}
