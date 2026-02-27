package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Role string

const (
	RoleClient Role = "client"
	RoleDriver Role = "driver"
	RoleVendor Role = "vendor"
)

type User struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey" json:"id"`
	Email      string         `gorm:"uniqueIndex;not null" json:"email"`
	Password   string         `gorm:"not null" json:"-"`
	Role       Role           `gorm:"type:varchar(20);not null" json:"role"`
	IsVerified bool           `gorm:"default:false" json:"is_verified"`
	OTP        string         `gorm:"type:varchar(6)" json:"-"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`

	// Profile relations
	ClientProfile *ClientProfile `json:"client_profile,omitempty"`
	DriverProfile *DriverProfile `json:"driver_profile,omitempty"`
	VendorProfile *VendorProfile `json:"vendor_profile,omitempty"`
}

func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return
}

type ClientProfile struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	UserID      uuid.UUID `gorm:"type:uuid;uniqueIndex;not null" json:"user_id"`
	FullName    string    `json:"full_name"`
	PhoneNumber string    `json:"phone_number"`
	Address     string    `json:"address"`
	City        string    `json:"city"`
}

type DriverProfile struct {
	ID              uint      `gorm:"primaryKey" json:"id"`
	UserID          uuid.UUID `gorm:"type:uuid;uniqueIndex;not null" json:"user_id"`
	FullName        string    `json:"full_name"`
	LicenseNo       string    `json:"license_no"`
	VehicleType     string    `json:"vehicle_type"`
	PlateNo         string    `json:"plate_no"`
	VehicleCapacity string    `json:"vehicle_capacity"`
}

type VendorProfile struct {
	ID                 uint      `gorm:"primaryKey" json:"id"`
	UserID             uuid.UUID `gorm:"type:uuid;uniqueIndex;not null" json:"user_id"`
	StoreName          string    `json:"store_name"`
	StoreDescription   string    `json:"store_description"`
	BusinessCategory   string    `json:"business_category"`
	StoreAddress       string    `json:"store_address"`
	RegistrationNumber string    `json:"registration_number"`
	Landmark           string    `json:"landmark"`
}

type Product struct {
	ID          uuid.UUID     `gorm:"type:uuid;primaryKey" json:"id"`
	VendorID    uuid.UUID     `gorm:"type:uuid;not null" json:"vendor_id"`
	Name        string        `gorm:"not null" json:"name"`
	Description string        `json:"description"`
	Price       float64       `gorm:"not null" json:"price"`
	Category    string        `gorm:"not null" json:"category"`
	MOQ         int           `gorm:"default:1" json:"moq"`
	Stock       int           `gorm:"default:0" json:"stock"`
	ImageURL    string        `json:"image_url"`
	Vendor      VendorProfile `gorm:"foreignKey:VendorID;references:UserID" json:"vendor"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

func (p *Product) BeforeCreate(tx *gorm.DB) (err error) {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return
}

type Order struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey" json:"id"`
	ClientID        uuid.UUID      `gorm:"type:uuid;not null" json:"client_id"`
	DriverID        *uuid.UUID     `gorm:"type:uuid" json:"driver_id,omitempty"`
	TotalAmount     float64        `gorm:"not null" json:"total_amount"`
	Status          string         `gorm:"default:'pending'" json:"status"`
	DeliveryAddress string         `json:"delivery_address"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
	Items           []OrderItem    `json:"items"`
}

type OrderItem struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	OrderID   uuid.UUID `gorm:"type:uuid;not null" json:"order_id"`
	ProductID uuid.UUID `gorm:"type:uuid;not null" json:"product_id"`
	Product   Product   `json:"product"`
	Quantity  int       `gorm:"not null" json:"quantity"`
	Price     float64   `gorm:"not null" json:"price"`
}

type Wallet struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	UserID    uuid.UUID `gorm:"type:uuid;uniqueIndex;not null" json:"user_id"`
	Balance   float64   `gorm:"default:0" json:"balance"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Transaction struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	WalletID  uint      `gorm:"not null" json:"wallet_id"`
	Amount    float64   `gorm:"not null" json:"amount"`
	Type      string    `json:"type"` // "credit" or "debit"
	Reference string    `json:"reference"`
	Status    string    `json:"status"` // "pending", "success", "failed"
	CreatedAt time.Time `json:"created_at"`
}

type Bid struct {
	ID                    uint      `gorm:"primaryKey" json:"id"`
	OrderID               uuid.UUID `gorm:"type:uuid;not null" json:"order_id"`
	DriverID              uuid.UUID `gorm:"type:uuid;not null" json:"driver_id"`
	Amount                float64   `gorm:"not null" json:"amount"`
	EstimatedPickupTime   string    `json:"estimated_pickup_time"`
	EstimatedDeliveryTime string    `json:"estimated_delivery_time"`
	Status                string    `gorm:"default:'pending'" json:"status"` // "pending", "accepted", "rejected"
	CreatedAt             time.Time `json:"created_at"`
}

type Conversation struct {
	ID        uuid.UUID      `gorm:"type:uuid;primaryKey" json:"id"`
	User1ID   uuid.UUID      `gorm:"type:uuid;not null" json:"user1_id"`
	User2ID   uuid.UUID      `gorm:"type:uuid;not null" json:"user2_id"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Messages  []Message      `json:"messages,omitempty"`
}

func (c *Conversation) BeforeCreate(tx *gorm.DB) (err error) {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	return
}

type Message struct {
	ID             uint           `gorm:"primaryKey" json:"id"`
	ConversationID uuid.UUID      `gorm:"type:uuid;not null;index" json:"conversation_id"`
	SenderID       uuid.UUID      `gorm:"type:uuid;not null" json:"sender_id"`
	Content        string         `gorm:"not null" json:"content"`
	CreatedAt      time.Time      `json:"created_at"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-"`
}
