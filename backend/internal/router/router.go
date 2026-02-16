package router

import (
	"net/http"

	"backend/internal/middleware"
	"backend/internal/proxy"
)

func New(
	authMW *middleware.AuthMiddleware,
	rateLimiter *middleware.RateLimiter,
	serviceProxy *proxy.ServiceProxy,
) http.Handler {
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok","service":"gateway"}`))
	})

	// Public routes — proxied to auth-service
	mux.Handle("POST /api/v1/auth/register", serviceProxy.AuthProxy())
	mux.Handle("POST /api/v1/auth/login", serviceProxy.AuthProxy())
	mux.Handle("POST /api/v1/auth/refresh", serviceProxy.AuthProxy())
	mux.Handle("POST /api/v1/auth/forgot-password", serviceProxy.AuthProxy())

	// Protected routes — require JWT, then proxy to auth-service
	mux.Handle("GET /api/v1/user/profile", authMW.RequireAuth(serviceProxy.AuthProxy()))
	mux.Handle("PUT /api/v1/user/profile", authMW.RequireAuth(serviceProxy.AuthProxy()))
	mux.Handle("GET /api/v1/user/usage", authMW.RequireAuth(serviceProxy.AuthProxy()))
	mux.Handle("GET /api/v1/users", authMW.RequireAuth(serviceProxy.AuthProxy()))
	mux.Handle("GET /api/v1/users/{id}", authMW.RequireAuth(serviceProxy.AuthProxy()))
	mux.Handle("DELETE /api/v1/auth/account", authMW.RequireAuth(serviceProxy.AuthProxy()))

	// Apply global middleware
	var handler http.Handler = mux
	handler = rateLimiter.Limit(handler)
	handler = middleware.CORS(handler)

	return handler
}
