package handlers

import (
	"log"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for development
	},
}

type SocketHandler struct {
	// Map of userID to their websocket connection
	clients map[uuid.UUID]*websocket.Conn
	mu      sync.Mutex
}

func NewSocketHandler() *SocketHandler {
	return &SocketHandler{
		clients: make(map[uuid.UUID]*websocket.Conn),
	}
}

func (h *SocketHandler) HandleWebSocket(c *gin.Context) {
	// In a real app, you'd get userID from the authenticated context
	// For simplicity, we'll take it from query param or you could use middleware
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id is required"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user_id"})
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("Failed to upgrade connection: %v", err)
		return
	}

	h.mu.Lock()
	h.clients[userID] = conn
	h.mu.Unlock()

	defer func() {
		h.mu.Lock()
		delete(h.clients, userID)
		h.mu.Unlock()
		conn.Close()
	}()

	for {
		var msg map[string]interface{}
		err := conn.ReadJSON(&msg)
		if err != nil {
			log.Printf("Error reading JSON: %v", err)
			break
		}

		// Handle events like "location_update"
		if eventType, ok := msg["type"].(string); ok {
			switch eventType {
			case "location_update":
				log.Printf("Location update from user %v: %v", userID, msg["data"])
				// Broadcast or notify relevant users (e.g., client of this driver)
			case "ping":
				conn.WriteJSON(map[string]string{"type": "pong"})
			}
		}
	}
}

// NotifyUser sends a real-time message to a specific user
func (h *SocketHandler) NotifyUser(userID uuid.UUID, payload interface{}) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if conn, ok := h.clients[userID]; ok {
		err := conn.WriteJSON(payload)
		if err != nil {
			log.Printf("Failed to notify user %v: %v", userID, err)
			conn.Close()
			delete(h.clients, userID)
		}
	}
}
