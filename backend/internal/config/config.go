package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Port      string
	DBURL     string
	JWTSecret string
	GinMode   string
}

func LoadConfig() *Config {
	// Try to load .env file, but don't fail if it's missing (it might be set via ENV)
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	return &Config{
		Port:      getEnv("PORT", "8080"),
		DBURL:     getEnv("DB_URL", "gopickup.db"),
		JWTSecret: getEnv("JWT_SECRET", "super-secret-production-key-change-me"),
		GinMode:   getEnv("GIN_MODE", "debug"),
	}
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}
