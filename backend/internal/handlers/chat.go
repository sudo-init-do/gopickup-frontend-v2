package handlers

import (
	"net/http"

	"gopickup-backend/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ChatHandler struct {
	DB     *gorm.DB
	Socket *SocketHandler
}

func NewChatHandler(db *gorm.DB, socket *SocketHandler) *ChatHandler {
	return &ChatHandler{DB: db, Socket: socket}
}

func (h *ChatHandler) GetChats(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var conversations []models.Conversation
	if err := h.DB.Where("user1_id = ? OR user2_id = ?", userID, userID).
		Order("updated_at desc").
		Find(&conversations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch chats"})
		return
	}

	c.JSON(http.StatusOK, conversations)
}

func (h *ChatHandler) GetMessages(c *gin.Context) {
	conversationIDStr := c.Param("id")
	conversationID, err := uuid.Parse(conversationIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid conversation ID"})
		return
	}

	var messages []models.Message
	if err := h.DB.Where("conversation_id = ?", conversationID).
		Order("created_at asc").
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch messages"})
		return
	}

	c.JSON(http.StatusOK, messages)
}

func (h *ChatHandler) SendMessage(c *gin.Context) {
	senderID, _ := c.Get("user_id")

	var req struct {
		RecipientID uuid.UUID `json:"recipient_id" binding:"required"`
		Content     string    `json:"content" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var conversation models.Conversation
	// Try to find existing conversation between these two users
	err := h.DB.Where("(user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)",
		senderID, req.RecipientID, req.RecipientID, senderID).First(&conversation).Error

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			// Create new conversation
			conversation = models.Conversation{
				User1ID: senderID.(uuid.UUID),
				User2ID: req.RecipientID,
			}
			if err := h.DB.Create(&conversation).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create conversation"})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}
	}

	message := models.Message{
		ConversationID: conversation.ID,
		SenderID:       senderID.(uuid.UUID),
		Content:        req.Content,
	}

	if err := h.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not send message"})
		return
	}

	// Update conversation's updated_at
	h.DB.Model(&conversation).Update("updated_at", message.CreatedAt)

	// Notify recipient via WebSocket if online
	h.Socket.NotifyUser(req.RecipientID, gin.H{
		"type": "new_message",
		"data": message,
	})

	c.JSON(http.StatusCreated, message)
}
