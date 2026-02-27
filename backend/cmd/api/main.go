package main

import (
	"log"
	"strings"

	"gopickup-backend/internal/config"
	"gopickup-backend/internal/handlers"
	"gopickup-backend/internal/middleware"
	"gopickup-backend/internal/models"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	cfg := config.LoadConfig()

	// Set Gin Mode
	gin.SetMode(cfg.GinMode)

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
		&models.Conversation{},
		&models.Message{},
	)

	// Initialize Handlers
	authHandler := handlers.NewAuthHandler(db, cfg.JWTSecret)
	productHandler := handlers.NewProductHandler(db)
	walletHandler := handlers.NewWalletHandler(db)
	jobHandler := handlers.NewJobHandler(db)
	orderHandler := handlers.NewOrderHandler(db)
	vendorHandler := handlers.NewVendorHandler(db)
	socketHandler := handlers.NewSocketHandler()
	chatHandler := handlers.NewChatHandler(db, socketHandler)

	r := gin.Default()

	// CORS Setup - Secure
	allowedOriginsList := strings.Split(cfg.AllowedOrigins, ",")

	r.Use(cors.New(cors.Config{
		AllowOrigins:     allowedOriginsList,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * 3600, // Cache preflight requests for 12 hours
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
			protectedAuth.Use(middleware.AuthMiddleware(cfg.JWTSecret))
			{
				protectedAuth.POST("/onboarding/complete", authHandler.CompleteOnboarding)
			}
		}

		// Products
		v1.GET("/products", productHandler.GetProducts)
		v1.GET("/products/:id", productHandler.GetProduct)

		// Protected Vendor Routes
		vendorGroup := v1.Group("/vendor")
		vendorGroup.Use(middleware.AuthMiddleware(cfg.JWTSecret), middleware.RoleMiddleware("vendor"))
		{
			vendorGroup.GET("/dashboard", vendorHandler.GetDashboard)
			vendorGroup.POST("/products", productHandler.CreateProduct)
		}

		// Wallet Routes
		wallet := v1.Group("/wallet")
		wallet.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			wallet.GET("/balance", walletHandler.GetBalance)
			wallet.GET("/transactions", walletHandler.GetTransactions)
			wallet.POST("/topup", walletHandler.TopUp)
		}

		// Job/Delivery Routes
		jobs := v1.Group("/jobs")
		jobs.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			jobs.GET("/available", middleware.RoleMiddleware("driver"), jobHandler.GetAvailableJobs)
			jobs.POST("/:id/bid", middleware.RoleMiddleware("driver"), jobHandler.SubmitBid)
		}

		// Chat Routes
		chat := v1.Group("/chats")
		chat.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			chat.GET("", chatHandler.GetChats)
			chat.GET("/:id/messages", chatHandler.GetMessages)
			chat.POST("/message", chatHandler.SendMessage)
		}

		// Order Routes
		orders := v1.Group("/orders")
		orders.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			orders.GET("", orderHandler.GetUserOrders)
			orders.POST("/checkout", orderHandler.CreateOrder)
			orders.PATCH("/:id/status", orderHandler.UpdateStatus)
		}

		// WebSocket
		v1.GET("/socket", socketHandler.HandleWebSocket)
	}

	log.Printf("Server starting on :%s...\n", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal("Server failed to start:", err)
	}
}
