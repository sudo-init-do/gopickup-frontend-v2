package handlers

import (
	"net/http"

	"gopickup-backend/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type JobHandler struct {
	DB *gorm.DB
}

func NewJobHandler(db *gorm.DB) *JobHandler {
	return &JobHandler{DB: db}
}

func (h *JobHandler) GetAvailableJobs(c *gin.Context) {
	var orders []models.Order
	// In a real app, we'd filter by driver location/service area
	if err := h.DB.Preload("Items").Where("status = ?", "searching_driver").Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch jobs"})
		return
	}

	c.JSON(http.StatusOK, orders)
}

func (h *JobHandler) SubmitBid(c *gin.Context) {
	driverID, _ := c.Get("user_id")
	orderIDStr := c.Param("id")
	orderID, _ := uuid.Parse(orderIDStr)

	var req struct {
		Amount                float64 `json:"amount" binding:"required"`
		EstimatedPickupTime   string  `json:"estimated_pickup_time"`
		EstimatedDeliveryTime string  `json:"estimated_delivery_time"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	bid := models.Bid{
		OrderID:               orderID,
		DriverID:              driverID.(uuid.UUID),
		Amount:                req.Amount,
		EstimatedPickupTime:   req.EstimatedPickupTime,
		EstimatedDeliveryTime: req.EstimatedDeliveryTime,
	}

	if err := h.DB.Create(&bid).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not submit bid"})
		return
	}

	c.JSON(http.StatusCreated, bid)
}
