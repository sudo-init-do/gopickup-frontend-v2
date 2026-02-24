package handlers

import (
	"net/http"

	"gopickup-backend/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderHandler struct {
	DB *gorm.DB
}

func NewOrderHandler(db *gorm.DB) *OrderHandler {
	return &OrderHandler{DB: db}
}

type CheckoutRequest struct {
	Items []struct {
		ProductID uuid.UUID `json:"product_id" binding:"required"`
		Quantity  int       `json:"quantity" binding:"required,gt=0"`
	} `json:"items" binding:"required"`
	DeliveryAddress string `json:"delivery_address" binding:"required"`
	PaymentMethod   string `json:"payment_method" binding:"required"` // "wallet" or "card"
}

func (h *OrderHandler) CreateOrder(c *gin.Context) {
	clientID, _ := c.Get("user_id")

	var req CheckoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Start Transaction
	err := h.DB.Transaction(func(tx *gorm.DB) error {
		var totalAmount float64
		var orderItems []models.OrderItem

		for _, itemReq := range req.Items {
			var product models.Product
			if err := tx.First(&product, "id = ?", itemReq.ProductID).Error; err != nil {
				return err // Product not found
			}

			itemPrice := product.Price * float64(itemReq.Quantity)
			totalAmount += itemPrice

			orderItems = append(orderItems, models.OrderItem{
				ProductID: product.ID,
				Quantity:  itemReq.Quantity,
				Price:     product.Price,
			})
		}

		// Create Order
		order := models.Order{
			ID:              uuid.New(),
			ClientID:        clientID.(uuid.UUID),
			TotalAmount:     totalAmount,
			Status:          "pending",
			DeliveryAddress: req.DeliveryAddress,
			Items:           orderItems,
		}

		if err := tx.Create(&order).Error; err != nil {
			return err
		}

		// If payment method is wallet, deduct balance
		if req.PaymentMethod == "wallet" {
			var wallet models.Wallet
			if err := tx.Where("user_id = ?", clientID).First(&wallet).Error; err != nil {
				return err
			}

			if wallet.Balance < totalAmount {
				return gorm.ErrInvalidData // Insufficient balance
			}

			wallet.Balance -= totalAmount
			tx.Save(&wallet)

			// Record Transaction
			tx.Create(&models.Transaction{
				WalletID:  wallet.ID,
				Amount:    totalAmount,
				Type:      "debit",
				Reference: "Order " + order.ID.String(),
				Status:    "success",
			})
		}

		c.Set("created_order", order)
		return nil
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process order: " + err.Error()})
		return
	}

	order, _ := c.Get("created_order")
	c.JSON(http.StatusCreated, order)
}

func (h *OrderHandler) GetUserOrders(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var orders []models.Order
	query := h.DB.Preload("Items")

	if role == string(models.RoleClient) {
		query = query.Where("client_id = ?", userID)
	} else if role == string(models.RoleDriver) {
		query = query.Where("driver_id = ?", userID)
	} else if role == string(models.RoleVendor) {
		// Vendors see orders containing their products
		// For simplicity in this demo, we'll fetch all but in real-app use join
		query = query.Joins("JOIN order_items ON order_items.order_id = orders.id").
			Joins("JOIN products ON products.id = order_items.product_id").
			Where("products.vendor_id = ?", userID).
			Distinct("orders.id")
	}

	if err := query.Order("created_at desc").Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch orders"})
		return
	}

	c.JSON(http.StatusOK, orders)
}

func (h *OrderHandler) UpdateStatus(c *gin.Context) {
	orderID := c.Param("id")
	var req struct {
		Status string `json:"status" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.DB.Model(&models.Order{}).Where("id = ?", orderID).Update("status", req.Status).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update order status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Order status updated to " + req.Status})
}
