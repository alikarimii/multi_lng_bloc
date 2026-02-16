package middleware

import (
	"net/http"
	"sync"
	"time"

	"golang.org/x/time/rate"
)

type RateLimiter struct {
	visitors map[string]*visitor
	mu       sync.RWMutex
	limit    int
}

type visitor struct {
	limiter  *rate.Limiter
	lastSeen time.Time
}

func NewRateLimiter(requestsPerMinute int) *RateLimiter {
	rl := &RateLimiter{
		visitors: make(map[string]*visitor),
		limit:    requestsPerMinute,
	}

	// Cleanup old visitors every 3 minutes
	go rl.cleanupVisitors()

	return rl
}

func (rl *RateLimiter) Limit(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip := getIP(r)

		rl.mu.Lock()
		v, exists := rl.visitors[ip]
		if !exists {
			limiter := rate.NewLimiter(rate.Limit(rl.limit)/60, rl.limit)
			rl.visitors[ip] = &visitor{limiter, time.Now()}
			v = rl.visitors[ip]
		}
		v.lastSeen = time.Now()
		rl.mu.Unlock()

		if !v.limiter.Allow() {
			respondJSON(w, http.StatusTooManyRequests, map[string]string{
				"error": "Rate limit exceeded. Please try again later.",
			})
			return
		}

		next.ServeHTTP(w, r)
	})
}

func (rl *RateLimiter) cleanupVisitors() {
	for {
		time.Sleep(3 * time.Minute)

		rl.mu.Lock()
		for ip, v := range rl.visitors {
			if time.Since(v.lastSeen) > 3*time.Minute {
				delete(rl.visitors, ip)
			}
		}
		rl.mu.Unlock()
	}
}

func getIP(r *http.Request) string {
	// Try X-Forwarded-For header first (for proxies)
	forwarded := r.Header.Get("X-Forwarded-For")
	if forwarded != "" {
		return forwarded
	}

	// Try X-Real-IP header
	realIP := r.Header.Get("X-Real-IP")
	if realIP != "" {
		return realIP
	}

	// Fall back to RemoteAddr
	return r.RemoteAddr
}
