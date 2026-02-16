package repository

import (
	"database/sql"
	"time"

	"backend/internal/models"

	"github.com/google/uuid"
)

type TokenRepository struct {
	db *sql.DB
}

func NewTokenRepository(db *sql.DB) *TokenRepository {
	return &TokenRepository{db: db}
}

func (r *TokenRepository) Create(userID, token string, expiresAt time.Time) (*models.RefreshToken, error) {
	refreshToken := &models.RefreshToken{
		ID:        uuid.New().String(),
		UserID:    userID,
		Token:     token,
		ExpiresAt: expiresAt,
		CreatedAt: time.Now(),
	}

	query := `
		INSERT INTO refresh_tokens (id, user_id, token, expires_at, created_at)
		VALUES ($1, $2, $3, $4, $5)
	`

	_, err := r.db.Exec(query, refreshToken.ID, refreshToken.UserID, refreshToken.Token, refreshToken.ExpiresAt, refreshToken.CreatedAt)
	if err != nil {
		return nil, err
	}

	return refreshToken, nil
}

func (r *TokenRepository) GetByToken(token string) (*models.RefreshToken, error) {
	refreshToken := &models.RefreshToken{}

	query := `
		SELECT id, user_id, token, expires_at, created_at
		FROM refresh_tokens
		WHERE token = $1 AND expires_at > $2
	`

	err := r.db.QueryRow(query, token, time.Now()).Scan(
		&refreshToken.ID,
		&refreshToken.UserID,
		&refreshToken.Token,
		&refreshToken.ExpiresAt,
		&refreshToken.CreatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return refreshToken, nil
}

func (r *TokenRepository) DeleteByToken(token string) error {
	query := `DELETE FROM refresh_tokens WHERE token = $1`
	_, err := r.db.Exec(query, token)
	return err
}

func (r *TokenRepository) DeleteByUserID(userID string) error {
	query := `DELETE FROM refresh_tokens WHERE user_id = $1`
	_, err := r.db.Exec(query, userID)
	return err
}

func (r *TokenRepository) CleanupExpired() error {
	query := `DELETE FROM refresh_tokens WHERE expires_at < $1`
	_, err := r.db.Exec(query, time.Now())
	return err
}
