package service

import (
	"errors"
	"time"

	"backend/internal/models"
	"backend/internal/repository"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrInvalidToken       = errors.New("invalid token")
)

type AuthService struct {
	userRepo  *repository.UserRepository
	tokenRepo *repository.TokenRepository
	jwtSecret string
	jwtExpiry time.Duration
}

func NewAuthService(
	userRepo *repository.UserRepository,
	tokenRepo *repository.TokenRepository,
	jwtSecret string,
	jwtExpiry time.Duration,
) *AuthService {
	return &AuthService{
		userRepo:  userRepo,
		tokenRepo: tokenRepo,
		jwtSecret: jwtSecret,
		jwtExpiry: jwtExpiry,
	}
}

func (s *AuthService) Register(email, password, name string) (*models.User, string, string, error) {
	// Hash password
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, "", "", err
	}

	// Create user
	user, err := s.userRepo.Create(email, string(passwordHash), name)
	if err != nil {
		return nil, "", "", err
	}

	// Generate tokens
	accessToken, err := s.generateAccessToken(user.ID)
	if err != nil {
		return nil, "", "", err
	}

	refreshToken, err := s.generateRefreshToken(user.ID)
	if err != nil {
		return nil, "", "", err
	}

	return user, accessToken, refreshToken, nil
}

func (s *AuthService) Login(email, password string) (*models.User, string, string, error) {
	// Get user by email
	user, err := s.userRepo.GetByEmail(email)
	if err != nil {
		if err == repository.ErrUserNotFound {
			return nil, "", "", ErrInvalidCredentials
		}
		return nil, "", "", err
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return nil, "", "", ErrInvalidCredentials
	}

	// Generate tokens
	accessToken, err := s.generateAccessToken(user.ID)
	if err != nil {
		return nil, "", "", err
	}

	refreshToken, err := s.generateRefreshToken(user.ID)
	if err != nil {
		return nil, "", "", err
	}

	return user, accessToken, refreshToken, nil
}

func (s *AuthService) RefreshToken(refreshToken string) (string, string, error) {
	// Verify refresh token exists in database
	token, err := s.tokenRepo.GetByToken(refreshToken)
	if err != nil {
		return "", "", err
	}

	if token == nil {
		return "", "", ErrInvalidToken
	}

	// Delete old refresh token
	if err := s.tokenRepo.DeleteByToken(refreshToken); err != nil {
		return "", "", err
	}

	// Generate new tokens
	accessToken, err := s.generateAccessToken(token.UserID)
	if err != nil {
		return "", "", err
	}

	newRefreshToken, err := s.generateRefreshToken(token.UserID)
	if err != nil {
		return "", "", err
	}

	return accessToken, newRefreshToken, nil
}

func (s *AuthService) GetUserByID(userID string) (*models.User, error) {
	return s.userRepo.GetByID(userID)
}

func (s *AuthService) UpdateProfile(userID, name string) error {
	return s.userRepo.Update(userID, name)
}

func (s *AuthService) DeleteAccount(userID string) error {
	// Delete all refresh tokens
	if err := s.tokenRepo.DeleteByUserID(userID); err != nil {
		return err
	}

	// Delete user
	return s.userRepo.Delete(userID)
}

func (s *AuthService) GetUsageStats(userID string) (map[string]int, error) {
	return s.userRepo.GetUsageStats(userID)
}

func (s *AuthService) generateAccessToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(s.jwtExpiry).Unix(),
		"iat":     time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}

func (s *AuthService) generateRefreshToken(userID string) (string, error) {
	tokenString := uuid.New().String()
	expiresAt := time.Now().Add(30 * 24 * time.Hour) // 30 days

	_, err := s.tokenRepo.Create(userID, tokenString, expiresAt)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}
