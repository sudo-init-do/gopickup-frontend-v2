package handlers

import (
	"net/http"

	"gopickup-backend/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type WalletHandler struct {
	DB *gorm.DB
}

func NewWalletHandler(db *gorm.DB) *WalletHandler {
	return &WalletHandler{DB: db}
}

func (h *WalletHandler) GetBalance(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var wallet models.Wallet
	if err := h.DB.FirstOrCreate(&wallet, models.Wallet{UserID: userID.(uuid.UUID)}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not retrieve wallet"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"balance": wallet.Balance,
	})
}

func (h *WalletHandler) GetTransactions(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var wallet models.Wallet
	if err := h.DB.Where("user_id = ?", userID).First(&wallet).Error; err != nil {
		c.JSON(http.StatusOK, []models.Transaction{})
		return
	}

	var transactions []models.Transaction
	h.DB.Where("wallet_id = ?", wallet.ID).Order("created_at desc").Find(&transactions)

	c.JSON(http.StatusOK, transactions)
}

func (h *WalletHandler) TopUp(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req struct {
		Amount           float64 `json:"amount" binding:"required,gt=0"`
		PaymentReference string  `json:"payment_reference" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Security Check: In a real-world scenario, the backend should verify correctly with Paystack/Flutterwave
	// using the payment_reference before updating the balance.
	// For this prototype, we'll implement a simple verification logic placeholder.
	if req.PaymentReference == "" || len(req.PaymentReference) < 10 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid payment reference provided"})
		return
	}

	var wallet models.Wallet
	if err := h.DB.FirstOrCreate(&wallet, models.Wallet{UserID: userID.(uuid.UUID)}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not retrieve wallet"})
		return
	}

	// Start transaction
	err := h.DB.Transaction(func(tx *gorm.DB) error {
		wallet.Balance += req.Amount
		if err := tx.Save(&wallet).Error; err != nil {
			return err
		}

		transaction := models.Transaction{
			WalletID:  wallet.ID,
			Amount:    req.Amount,
			Type:      "credit",
			Reference: "Top-up: " + req.PaymentReference,
			Status:    "success",
		}

		if err := tx.Create(&transaction).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process top-up: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Wallet topped up successfully", "new_balance": wallet.Balance})
}
