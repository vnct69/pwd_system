package middleware

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

var envLoaded = false

// LoadEnv loads the .env file once at startup
func LoadEnv() {
	if err := godotenv.Load(".env"); err != nil {
		log.Println("Warning: .env file not found, relying on system environment variables")
	}
	envLoaded = true
}

// GetEnv retrieves the environment variable by key
func GetEnv(key string) string {
	if !envLoaded {
		LoadEnv() // Safety: load if not already loaded
	}
	return os.Getenv(key)
}
