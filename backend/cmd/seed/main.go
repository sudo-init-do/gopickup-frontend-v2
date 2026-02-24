package main

import (
	"log"

	"gopickup-backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	db, err := gorm.Open(sqlite.Open("gopickup.db"), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	// Ensure tables exist before seeding
	db.AutoMigrate(&models.Product{})

	vendorID := uuid.New()

	products := []models.Product{
		{
			ID:          uuid.New(),
			VendorID:    vendorID,
			Name:        "Dangote Cement (50kg)",
			Description: "High-quality portland cement",
			Price:       5000.0,
			Category:    "Cement",
			MOQ:         10,
			Stock:       500,
		},
		{
			ID:          uuid.New(),
			VendorID:    vendorID,
			Name:        "Steel Rebar (12mm)",
			Description: "Reinforcement steel for construction",
			Price:       8500.0,
			Category:    "Steel",
			MOQ:         50,
			Stock:       200,
		},
		{
			ID:          uuid.New(),
			VendorID:    vendorID,
			Name:        "Granite (1 ton)",
			Description: "Crushed granite for concrete",
			Price:       25000.0,
			Category:    "Quarry Materials",
			MOQ:         1,
			Stock:       100,
		},
	}

	for _, p := range products {
		db.Create(&p)
	}

	log.Println("Database seeded with", len(products), "products!")
}
