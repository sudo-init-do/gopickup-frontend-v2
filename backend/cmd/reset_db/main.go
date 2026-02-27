package main

import (
	"log"
	"strings"

	"gopickup-backend/internal/config"

	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	cfg := config.LoadConfig()

	// Initialize Database
	var db *gorm.DB
	var err error

	if strings.HasPrefix(cfg.DBURL, "postgres://") || strings.HasPrefix(cfg.DBURL, "postgresql://") || strings.Contains(cfg.DBURL, "sslmode=") {
		db, err = gorm.Open(postgres.Open(cfg.DBURL), &gorm.Config{})
		log.Println("✅ Connected to PostgreSQL database")
	} else {
		db, err = gorm.Open(sqlite.Open(cfg.DBURL), &gorm.Config{})
		log.Println("📁 Using SQLite file-based database:", cfg.DBURL)
	}

	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	log.Println("⚠️  Wiping all data from database...")

	// Order matters for foreign keys
	db.Exec("DELETE FROM messages")
	db.Exec("DELETE FROM conversations")
	db.Exec("DELETE FROM bids")
	db.Exec("DELETE FROM transactions")
	db.Exec("DELETE FROM wallets")
	db.Exec("DELETE FROM order_items")
	db.Exec("DELETE FROM orders")
	db.Exec("DELETE FROM products")
	db.Exec("DELETE FROM vendor_profiles")
	db.Exec("DELETE FROM driver_profiles")
	db.Exec("DELETE FROM client_profiles")
	db.Exec("DELETE FROM users")

	log.Println("✅ Database cleared successfully!")
}
