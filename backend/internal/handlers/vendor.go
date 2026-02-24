package handlers

import (
	"net/http"

	"gopickup-backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type VendorHandler struct {
	DB *gorm.DB
}

func NewVendorHandler(db *gorm.DB) *VendorHandler {
	return &VendorHandler{DB: db}
}

func (h *VendorHandler) GetDashboard(c *gin.Context) {
	vendorID, _ := c.Get("user_id")

	var stats struct {
		TotalRevenue   float64 `json:"totalRevenue"`
		OrdersToday    int64   `json:"ordersToday"`
		ProductsActive int64   `json:"productsActive"`
		ProfileViews   int     `json:"profileViews"`
	}

	// Calculate Total Revenue from successful orders containing vendor's products
	h.DB.Table("order_items").
		Select("SUM(order_items.price * order_items.quantity)").
		Joins("JOIN products ON products.id = order_items.product_id").
		Joins("JOIN orders ON orders.id = order_items.order_id").
		Where("products.vendor_id = ?", vendorID).
		Where("orders.status IN ?", []string{"delivered", "transit", "processing"}).
		Scan(&stats.TotalRevenue)

	// Count today's orders
	h.DB.Table("orders").
		Joins("JOIN order_items ON order_items.order_id = orders.id").
		Joins("JOIN products ON products.id = order_items.product_id").
		Where("products.vendor_id = ?", vendorID).
		Where("orders.created_at >= date('now')").
		Distinct("orders.id").
		Count(&stats.OrdersToday)

	// Count active products
	h.DB.Model(&models.Product{}).Where("vendor_id = ?", vendorID).Count(&stats.ProductsActive)

	// Profile views (Mock for now)
	stats.ProfileViews = 2300

	c.JSON(http.StatusOK, stats)
}
