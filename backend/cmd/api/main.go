package main

import (
	"log"

	"gopickup-backend/internal/handlers"
	"gopickup-backend/internal/middleware"
	"gopickup-backend/internal/models"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	// Initialize Database (Using SQLite for local development)
	db, err := gorm.Open(sqlite.Open("gopickup.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Automigrate models
	db.AutoMigrate(
		&models.User{},
		&models.ClientProfile{},
		&models.DriverProfile{},
		&models.VendorProfile{},
		&models.Product{},
		&models.Order{},
		&models.OrderItem{},
		&models.Wallet{},
		&models.Transaction{},
		&models.Bid{},
	)

	// Initialize Handlers
	authHandler := handlers.NewAuthHandler(db)
	productHandler := handlers.NewProductHandler(db)
	walletHandler := handlers.NewWalletHandler(db)
	jobHandler := handlers.NewJobHandler(db)
	orderHandler := handlers.NewOrderHandler(db)

	r := gin.Default()

	// CORS Setup
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	// API Routes V1
	v1 := r.Group("/api/v1")
	{
		// Auth
		auth := v1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/verify-otp", authHandler.VerifyOTP)

			// Protected Auth Routes
			protectedAuth := auth.Group("")
			protectedAuth.Use(middleware.AuthMiddleware())
			{
				protectedAuth.POST("/onboarding/complete", authHandler.CompleteOnboarding)
			}
		}

		// Products
		v1.GET("/products", productHandler.GetProducts)
		v1.GET("/products/:id", productHandler.GetProduct)

		// Protected Vendor Routes
		vendorGroup := v1.Group("/vendor")
		vendorGroup.Use(middleware.AuthMiddleware(), middleware.RoleMiddleware("vendor"))
		{
			vendorGroup.POST("/products", productHandler.CreateProduct)
		}

		// Wallet Routes
		wallet := v1.Group("/wallet")
		wallet.Use(middleware.AuthMiddleware())
		{
			wallet.GET("/balance", walletHandler.GetBalance)
			wallet.GET("/transactions", walletHandler.GetTransactions)
			wallet.POST("/topup", walletHandler.TopUp)
		}

		// Job/Delivery Routes
		jobs := v1.Group("/jobs")
		jobs.Use(middleware.AuthMiddleware())
		{
			jobs.GET("/available", middleware.RoleMiddleware("driver"), jobHandler.GetAvailableJobs)
			jobs.POST("/:id/bid", middleware.RoleMiddleware("driver"), jobHandler.SubmitBid)
		}

		// Order Routes
		orders := v1.Group("/orders")
		orders.Use(middleware.AuthMiddleware())
		{
			orders.GET("", orderHandler.GetUserOrders)
			orders.POST("/checkout", orderHandler.CreateOrder)
			orders.PATCH("/:id/status", orderHandler.UpdateStatus)
		}
	}

	log.Println("Server starting on :8080...")
	if err := r.Run(":8080"); err != nil {
		log.Fatal("Server failed to start:", err)
	}
}
