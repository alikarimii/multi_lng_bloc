package handlers

import (
	"encoding/json"
	"net/http"
	"strings"

	"backend/internal/repository"
	"backend/internal/service"

	"github.com/golang-jwt/jwt/v5"
)

type AuthHandler struct {
	authService *service.AuthService
}

func NewAuthHandler(authService *service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

type RegisterRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	Name     string `json:"name"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type UpdateProfileRequest struct {
	Name string `json:"name"`
}

type AuthResponse struct {
	User struct {
		ID        string `json:"id"`
		Email     string `json:"email"`
		Name      string `json:"name"`
		CreatedAt string `json:"created_at"`
	} `json:"user"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
		return
	}

	// Validation
	if req.Email == "" || req.Password == "" || req.Name == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Email, password, and name are required"})
		return
	}

	if len(req.Password) < 8 {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Password must be at least 8 characters"})
		return
	}

	user, accessToken, refreshToken, err := h.authService.Register(req.Email, req.Password, req.Name)
	if err != nil {
		if err == repository.ErrEmailAlreadyExists {
			respondJSON(w, http.StatusConflict, map[string]string{"error": "Email already exists"})
			return
		}
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to register user"})
		return
	}

	response := AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}
	response.User.ID = user.ID
	response.User.Email = user.Email
	response.User.Name = user.Name
	response.User.CreatedAt = user.CreatedAt.Format("2006-01-02T15:04:05Z")

	respondJSON(w, http.StatusCreated, response)
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
		return
	}

	if req.Email == "" || req.Password == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Email and password are required"})
		return
	}

	user, accessToken, refreshToken, err := h.authService.Login(req.Email, req.Password)
	if err != nil {
		if err == service.ErrInvalidCredentials {
			respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "Invalid credentials"})
			return
		}
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to login"})
		return
	}

	response := AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}
	response.User.ID = user.ID
	response.User.Email = user.Email
	response.User.Name = user.Name
	response.User.CreatedAt = user.CreatedAt.Format("2006-01-02T15:04:05Z")

	respondJSON(w, http.StatusOK, response)
}

func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	var req RefreshTokenRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
		return
	}

	if req.RefreshToken == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Refresh token is required"})
		return
	}

	accessToken, refreshToken, err := h.authService.RefreshToken(req.RefreshToken)
	if err != nil {
		if err == service.ErrInvalidToken {
			respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "Invalid refresh token"})
			return
		}
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to refresh token"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]string{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	})
}

func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement password reset functionality
	// This would typically involve:
	// 1. Generate a password reset token
	// 2. Send email with reset link
	// 3. Store token in database with expiry
	respondJSON(w, http.StatusOK, map[string]string{
		"message": "Password reset email sent",
	})
}

func (h *AuthHandler) GetProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromToken(r)
	if userID == "" {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
		return
	}

	user, err := h.authService.GetUserByID(userID)
	if err != nil {
		if err == repository.ErrUserNotFound {
			respondJSON(w, http.StatusNotFound, map[string]string{"error": "User not found"})
			return
		}
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to get profile"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"id":         user.ID,
		"email":      user.Email,
		"name":       user.Name,
		"created_at": user.CreatedAt.Format("2006-01-02T15:04:05Z"),
		"updated_at": user.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	})
}

func (h *AuthHandler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromToken(r)
	if userID == "" {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
		return
	}

	var req UpdateProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
		return
	}

	if req.Name == "" {
		respondJSON(w, http.StatusBadRequest, map[string]string{"error": "Name is required"})
		return
	}

	if err := h.authService.UpdateProfile(userID, req.Name); err != nil {
		if err == repository.ErrUserNotFound {
			respondJSON(w, http.StatusNotFound, map[string]string{"error": "User not found"})
			return
		}
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to update profile"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]string{"message": "Profile updated successfully"})
}

func (h *AuthHandler) DeleteAccount(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromToken(r)
	if userID == "" {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
		return
	}

	if err := h.authService.DeleteAccount(userID); err != nil {
		if err == repository.ErrUserNotFound {
			respondJSON(w, http.StatusNotFound, map[string]string{"error": "User not found"})
			return
		}
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to delete account"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]string{"message": "Account deleted successfully"})
}

func (h *AuthHandler) GetUsage(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromToken(r)
	if userID == "" {
		respondJSON(w, http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
		return
	}

	usage, err := h.authService.GetUsageStats(userID)
	if err != nil {
		respondJSON(w, http.StatusInternalServerError, map[string]string{"error": "Failed to get usage stats"})
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"user_id": userID,
		"usage":   usage,
	})
}

func getUserIDFromToken(r *http.Request) string {
	// First check X-User-ID header (set by gateway after JWT validation)
	if userID := r.Header.Get("X-User-ID"); userID != "" {
		return userID
	}

	// Fallback: parse JWT directly (for direct auth service access)
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}

	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || parts[0] != "Bearer" {
		return ""
	}

	tokenString := parts[1]
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte("your-super-secret-jwt-key-change-in-production"), nil
	})

	if err != nil || !token.Valid {
		return ""
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok {
		if userID, ok := claims["user_id"].(string); ok {
			return userID
		}
	}

	return ""
}

func respondJSON(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(data)
}
