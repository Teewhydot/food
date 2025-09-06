package models

import (
	"time"
	"database/sql/driver"
	"encoding/json"
	"errors"
	"fmt"
)

// MariaDB specific optimizations and data types

// ==============================================================================
// AUTHENTICATION & USER MODELS
// ==============================================================================

// User represents the main user entity - optimized for MariaDB
type User struct {
	ID               string    `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	FirstName        string    `json:"firstName" gorm:"column:first_name;type:varchar(100);not null"`
	LastName         string    `json:"lastName" gorm:"column:last_name;type:varchar(100);not null"`
	Email            string    `json:"email" gorm:"column:email;type:varchar(255);uniqueIndex;not null"`
	PhoneNumber      string    `json:"phoneNumber" gorm:"column:phone_number;type:varchar(20);not null;index"`
	ProfileImageURL  *string   `json:"profileImageUrl,omitempty" gorm:"column:profile_image_url;type:text"`
	Bio              *string   `json:"bio,omitempty" gorm:"column:bio;type:text"`
	FirstTimeLogin   bool      `json:"firstTimeLogin" gorm:"column:first_time_login;type:tinyint(1);default:1"`
	EmailVerified    bool      `json:"emailVerified" gorm:"column:email_verified;type:tinyint(1);default:0"`
	FCMToken         *string   `json:"fcmToken,omitempty" gorm:"column:fcm_token;type:text"`
	CreatedAt        time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt        time.Time `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
}

// LocationData represents location information - optimized for MariaDB
type LocationData struct {
	Latitude  float64 `json:"latitude" gorm:"column:latitude;type:decimal(10,8);not null"`
	Longitude float64 `json:"longitude" gorm:"column:longitude;type:decimal(11,8);not null"`
	Address   string  `json:"address" gorm:"column:address;type:varchar(500);not null"`
	City      string  `json:"city" gorm:"column:city;type:varchar(100);not null"`
	Country   string  `json:"country" gorm:"column:country;type:varchar(100);not null"`
}

// Address represents user address entity - optimized for MariaDB
type Address struct {
	ID        string   `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	UserID    string   `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index"`
	Street    string   `json:"street" gorm:"column:street;type:varchar(255);not null"`
	City      string   `json:"city" gorm:"column:city;type:varchar(100);not null"`
	State     string   `json:"state" gorm:"column:state;type:varchar(100);not null"`
	ZipCode   string   `json:"zipCode" gorm:"column:zip_code;type:varchar(20);not null"`
	Type      string   `json:"type" gorm:"column:type;type:enum('home','work','other');default:'home'"`
	Address   string   `json:"address" gorm:"column:address;type:varchar(500);not null"`
	Apartment string   `json:"apartment" gorm:"column:apartment;type:varchar(100);not null"`
	Title     *string  `json:"title,omitempty" gorm:"column:title;type:varchar(100)"`
	Latitude  *float64 `json:"latitude,omitempty" gorm:"column:latitude;type:decimal(10,8)"`
	Longitude *float64 `json:"longitude,omitempty" gorm:"column:longitude;type:decimal(11,8)"`
	IsDefault bool     `json:"isDefault" gorm:"column:is_default;type:tinyint(1);default:0"`
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt time.Time `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	User      User     `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// Permission represents permission entity - optimized for MariaDB
type Permission struct {
	PermissionName string    `json:"permissionName" gorm:"primaryKey;column:permission_name;type:varchar(100)"`
	UserID         string    `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index"`
	IsGranted      bool      `json:"isGranted" gorm:"column:is_granted;type:tinyint(1);not null"`
	LastUpdated    time.Time `json:"lastUpdated" gorm:"column:last_updated;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	User           User      `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// ==============================================================================
// RESTAURANT MODELS
// ==============================================================================

// StringArray is a custom type for handling string arrays in GORM
type StringArray []string

func (sa StringArray) Value() (driver.Value, error) {
	return json.Marshal(sa)
}

func (sa *StringArray) Scan(value interface{}) error {
	if value == nil {
		*sa = nil
		return nil
	}
	
	bytes, ok := value.([]byte)
	if !ok {
		return errors.New("type assertion to []byte failed")
	}
	
	return json.Unmarshal(bytes, sa)
}

// Restaurant represents the restaurant entity - optimized for MariaDB
type Restaurant struct {
	ID           string                     `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	Name         string                     `json:"name" gorm:"column:name;type:varchar(255);not null;index"`
	Description  string                     `json:"description" gorm:"column:description;type:text;not null"`
	Location     string                     `json:"location" gorm:"column:location;type:varchar(500);not null"`
	Distance     float64                    `json:"distance" gorm:"column:distance;type:decimal(8,2);default:0.00"`
	Rating       float64                    `json:"rating" gorm:"column:rating;type:decimal(3,2);default:0.00;index"`
	DeliveryTime string                     `json:"deliveryTime" gorm:"column:delivery_time;type:varchar(50);not null"`
	DeliveryFee  float64                    `json:"deliveryFee" gorm:"column:delivery_fee;type:decimal(8,2);not null"`
	ImageURL     string                     `json:"imageUrl" gorm:"column:image_url;type:text;not null"`
	Categories   StringArray                `json:"categories" gorm:"column:categories;type:json"`
	IsOpen       bool                       `json:"isOpen" gorm:"column:is_open;type:tinyint(1);default:1;index"`
	Latitude     float64                    `json:"latitude" gorm:"column:latitude;type:decimal(10,8);not null"`
	Longitude    float64                    `json:"longitude" gorm:"column:longitude;type:decimal(11,8);not null"`
	CreatedAt    time.Time                  `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt    time.Time                  `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	Foods        []Food                     `json:"foods,omitempty" gorm:"foreignKey:RestaurantID"`
	FoodCategories []RestaurantFoodCategory `json:"foodCategories,omitempty" gorm:"foreignKey:RestaurantID"`
}

// RestaurantFoodCategory represents food categories within a restaurant
type RestaurantFoodCategory struct {
	ID           uint   `json:"id" gorm:"primaryKey;autoIncrement"`
	RestaurantID string `json:"restaurantId" gorm:"column:restaurant_id;not null;index"`
	Category     string `json:"category" gorm:"column:category;not null"`
	ImageURL     string `json:"imageUrl" gorm:"column:image_url;not null"`
	Restaurant   Restaurant `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID"`
	Foods        []Food `json:"foods,omitempty" gorm:"foreignKey:RestaurantID,Category;references:RestaurantID,Category"`
}

// ==============================================================================
// FOOD MODELS
// ==============================================================================

// Food represents the food entity
type Food struct {
	ID              string      `json:"id" gorm:"primaryKey;column:id"`
	Name            string      `json:"name" gorm:"column:name;not null;index"`
	Description     string      `json:"description" gorm:"column:description;not null"`
	Price           float64     `json:"price" gorm:"column:price;not null"`
	Rating          float64     `json:"rating" gorm:"column:rating;default:0.0"`
	ImageURL        string      `json:"imageUrl" gorm:"column:image_url;not null"`
	Category        string      `json:"category" gorm:"column:category;not null;index"`
	RestaurantID    string      `json:"restaurantId" gorm:"column:restaurant_id;not null;index"`
	RestaurantName  string      `json:"restaurantName" gorm:"column:restaurant_name;not null"`
	Ingredients     StringArray `json:"ingredients" gorm:"column:ingredients;type:json"`
	IsAvailable     bool        `json:"isAvailable" gorm:"column:is_available;default:true"`
	PreparationTime string      `json:"preparationTime" gorm:"column:preparation_time"`
	Calories        int         `json:"calories" gorm:"column:calories;default:0"`
	Quantity        int         `json:"quantity" gorm:"column:quantity;default:1"`
	IsVegetarian    bool        `json:"isVegetarian" gorm:"column:is_vegetarian;default:false"`
	IsVegan         bool        `json:"isVegan" gorm:"column:is_vegan;default:false"`
	IsGlutenFree    bool        `json:"isGlutenFree" gorm:"column:is_gluten_free;default:false"`
	CreatedAt       time.Time   `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	UpdatedAt       time.Time   `json:"updatedAt" gorm:"column:updated_at;autoUpdateTime"`
	Restaurant      Restaurant  `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID"`
}

// ==============================================================================
// ORDER & PAYMENT MODELS
// ==============================================================================

// OrderStatus represents order status enum
type OrderStatus string

const (
	OrderStatusPending   OrderStatus = "pending"
	OrderStatusConfirmed OrderStatus = "confirmed"
	OrderStatusPreparing OrderStatus = "preparing"
	OrderStatusOnTheWay  OrderStatus = "onTheWay"
	OrderStatusDelivered OrderStatus = "delivered"
	OrderStatusCancelled OrderStatus = "cancelled"
)

// OrderItem represents individual items in an order
type OrderItem struct {
	FoodID              string  `json:"foodId"`
	FoodName            string  `json:"foodName"`
	Price               float64 `json:"price"`
	Quantity            int     `json:"quantity"`
	Total               float64 `json:"total"`
	SpecialInstructions *string `json:"specialInstructions,omitempty"`
}

// OrderItemsArray is a custom type for handling order items array
type OrderItemsArray []OrderItem

func (oia OrderItemsArray) Value() (driver.Value, error) {
	return json.Marshal(oia)
}

func (oia *OrderItemsArray) Scan(value interface{}) error {
	if value == nil {
		*oia = nil
		return nil
	}
	
	bytes, ok := value.([]byte)
	if !ok {
		return errors.New("type assertion to []byte failed")
	}
	
	return json.Unmarshal(bytes, oia)
}

// Order represents the order entity
type Order struct {
	ID                   string          `json:"id" gorm:"primaryKey;column:id"`
	UserID               string          `json:"userId" gorm:"column:user_id;not null;index"`
	RestaurantID         string          `json:"restaurantId" gorm:"column:restaurant_id;not null;index"`
	RestaurantName       string          `json:"restaurantName" gorm:"column:restaurant_name;not null"`
	Items                OrderItemsArray `json:"items" gorm:"column:items;type:json;not null"`
	Subtotal             float64         `json:"subtotal" gorm:"column:subtotal;not null"`
	DeliveryFee          float64         `json:"deliveryFee" gorm:"column:delivery_fee;not null"`
	Tax                  float64         `json:"tax" gorm:"column:tax;not null"`
	Total                float64         `json:"total" gorm:"column:total;not null"`
	DeliveryAddress      string          `json:"deliveryAddress" gorm:"column:delivery_address;not null"`
	PaymentMethod        string          `json:"paymentMethod" gorm:"column:payment_method;not null"`
	Status               OrderStatus     `json:"status" gorm:"column:status;not null;default:'pending'"`
	DeliveryPersonName   *string         `json:"deliveryPersonName,omitempty" gorm:"column:delivery_person_name"`
	DeliveryPersonPhone  *string         `json:"deliveryPersonPhone,omitempty" gorm:"column:delivery_person_phone"`
	TrackingURL          *string         `json:"trackingUrl,omitempty" gorm:"column:tracking_url"`
	Notes                *string         `json:"notes,omitempty" gorm:"column:notes"`
	CreatedAt            time.Time       `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	UpdatedAt            time.Time       `json:"updatedAt" gorm:"column:updated_at;autoUpdateTime"`
	DeliveredAt          *time.Time      `json:"deliveredAt,omitempty" gorm:"column:delivered_at"`
	User                 User            `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Restaurant           Restaurant      `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID"`
}

// PaymentMethod represents payment method entity
type PaymentMethod struct {
	ID      string `json:"id" gorm:"primaryKey;column:id"`
	Name    string `json:"name" gorm:"column:name;not null"`
	Type    string `json:"type" gorm:"column:type;not null"`
	IconURL string `json:"iconUrl" gorm:"column:icon_url;not null"`
}

// Card represents payment card entity
type Card struct {
	ID                   string        `json:"id" gorm:"primaryKey;column:id"`
	UserID               string        `json:"userId" gorm:"column:user_id;not null;index"`
	PaymentMethodID      string        `json:"paymentMethodId" gorm:"column:payment_method_id;not null"`
	PAN                  string        `json:"pan" gorm:"column:pan;not null"` // Should be encrypted
	CVV                  string        `json:"cvv" gorm:"column:cvv;not null"` // Should be encrypted
	ExpiryMonth          int           `json:"mExp" gorm:"column:expiry_month;not null"`
	ExpiryYear           int           `json:"yExp" gorm:"column:expiry_year;not null"`
	CardholderName       string        `json:"cardholderName" gorm:"column:cardholder_name;not null"`
	IsDefault            bool          `json:"isDefault" gorm:"column:is_default;default:false"`
	CreatedAt            time.Time     `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	UpdatedAt            time.Time     `json:"updatedAt" gorm:"column:updated_at;autoUpdateTime"`
	User                 User          `json:"user,omitempty" gorm:"foreignKey:UserID"`
	PaymentMethod        PaymentMethod `json:"paymentMethod,omitempty" gorm:"foreignKey:PaymentMethodID"`
}

// PaymentTransaction represents payment transaction entity
type PaymentTransaction struct {
	ID                string      `json:"id" gorm:"primaryKey;column:id"`
	OrderID           string      `json:"orderId" gorm:"column:order_id;not null;index"`
	UserID            string      `json:"userId" gorm:"column:user_id;not null;index"`
	PaymentMethodID   string      `json:"paymentMethodId" gorm:"column:payment_method_id;not null"`
	Amount            float64     `json:"amount" gorm:"column:amount;not null"`
	Currency          string      `json:"currency" gorm:"column:currency;default:'USD';not null"`
	Status            string      `json:"status" gorm:"column:status;not null"` // pending, completed, failed, refunded
	TransactionID     *string     `json:"transactionId,omitempty" gorm:"column:transaction_id"` // External payment gateway transaction ID
	FailureReason     *string     `json:"failureReason,omitempty" gorm:"column:failure_reason"`
	ProcessedAt       *time.Time  `json:"processedAt,omitempty" gorm:"column:processed_at"`
	CreatedAt         time.Time   `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	UpdatedAt         time.Time   `json:"updatedAt" gorm:"column:updated_at;autoUpdateTime"`
	Order             Order       `json:"order,omitempty" gorm:"foreignKey:OrderID"`
	User              User        `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

// Cart represents cart entity (typically handled in memory/session)
type Cart struct {
	UserID     string  `json:"userId"`
	Items      []Food  `json:"items"`
	TotalPrice float64 `json:"totalPrice"`
	ItemCount  int     `json:"itemCount"`
}

// ==============================================================================
// CHAT & MESSAGING MODELS
// ==============================================================================

// Chat represents chat entity
type Chat struct {
	ID              string    `json:"id" gorm:"primaryKey;column:id"`
	SenderID        string    `json:"senderId" gorm:"column:sender_id;not null;index"`
	ReceiverID      string    `json:"receiverId" gorm:"column:receiver_id;not null;index"`
	OrderID         *string   `json:"orderId,omitempty" gorm:"column:order_id;index"`
	Name            string    `json:"name" gorm:"column:name;not null"`
	LastMessage     string    `json:"lastMessage" gorm:"column:last_message"`
	ImageURL        string    `json:"imageUrl" gorm:"column:image_url"`
	LastMessageTime time.Time `json:"lastMessageTime" gorm:"column:last_message_time;autoUpdateTime"`
	CreatedAt       time.Time `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	UpdatedAt       time.Time `json:"updatedAt" gorm:"column:updated_at;autoUpdateTime"`
	Sender          User      `json:"sender,omitempty" gorm:"foreignKey:SenderID"`
	Receiver        User      `json:"receiver,omitempty" gorm:"foreignKey:ReceiverID"`
	Order           *Order    `json:"order,omitempty" gorm:"foreignKey:OrderID"`
	Messages        []Message `json:"messages,omitempty" gorm:"foreignKey:ChatID"`
}

// Message represents message entity
type Message struct {
	ID         string    `json:"id" gorm:"primaryKey;column:id"`
	ChatID     string    `json:"chatId" gorm:"column:chat_id;not null;index"`
	Content    string    `json:"content" gorm:"column:content;not null"`
	SenderID   string    `json:"senderId" gorm:"column:sender_id;not null;index"`
	ReceiverID string    `json:"receiverId" gorm:"column:receiver_id;not null;index"`
	IsRead     bool      `json:"isRead" gorm:"column:is_read;default:false"`
	MessageType string   `json:"messageType" gorm:"column:message_type;default:'text'"` // text, image, file
	FileURL     *string   `json:"fileUrl,omitempty" gorm:"column:file_url"`
	CreatedAt   time.Time `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	Chat        Chat      `json:"chat,omitempty" gorm:"foreignKey:ChatID"`
	Sender      User      `json:"sender,omitempty" gorm:"foreignKey:SenderID"`
	Receiver    User      `json:"receiver,omitempty" gorm:"foreignKey:ReceiverID"`
}

// ==============================================================================
// NOTIFICATION MODELS
// ==============================================================================

// Notification represents notification entity
type Notification struct {
	ID        string    `json:"id" gorm:"primaryKey;column:id"`
	UserID    string    `json:"userId" gorm:"column:user_id;not null;index"`
	Title     string    `json:"title" gorm:"column:title;not null"`
	Body      string    `json:"body" gorm:"column:body;not null"`
	Type      string    `json:"type" gorm:"column:type;not null"` // order, promotion, system, chat
	IsRead    bool      `json:"isRead" gorm:"column:is_read;default:false"`
	Data      *string   `json:"data,omitempty" gorm:"column:data;type:json"` // Additional data as JSON
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	User      User      `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

// ==============================================================================
// FAVORITES MODELS
// ==============================================================================

// FavoriteFood represents favorite food entity
type FavoriteFood struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    string    `json:"userId" gorm:"column:user_id;not null;index"`
	FoodID    string    `json:"foodId" gorm:"column:food_id;not null;index"`
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	User      User      `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Food      Food      `json:"food,omitempty" gorm:"foreignKey:FoodID"`
}

// FavoriteRestaurant represents favorite restaurant entity
type FavoriteRestaurant struct {
	ID           uint       `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       string     `json:"userId" gorm:"column:user_id;not null;index"`
	RestaurantID string     `json:"restaurantId" gorm:"column:restaurant_id;not null;index"`
	CreatedAt    time.Time  `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	User         User       `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Restaurant   Restaurant `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID"`
}

// ==============================================================================
// SEARCH & UTILITY MODELS
// ==============================================================================

// RecentKeyword represents recent search keyword entity
type RecentKeyword struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    string    `json:"userId" gorm:"column:user_id;not null;index"`
	Keyword   string    `json:"keyword" gorm:"column:keyword;not null;index"`
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;autoCreateTime"`
	User      User      `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

// SearchResult represents search result entity (for caching)
type SearchResult struct {
	Query       string      `json:"query"`
	Type        string      `json:"type"` // food, restaurant, mixed
	Results     interface{} `json:"results"`
	ResultCount int         `json:"resultCount"`
	Timestamp   time.Time   `json:"timestamp"`
}

// ==============================================================================
// API RESPONSE MODELS
// ==============================================================================

// APIResponse represents standard API response structure
type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   *APIError   `json:"error,omitempty"`
}

// APIError represents API error structure
type APIError struct {
	Code    string      `json:"code"`
	Message string      `json:"message"`
	Details interface{} `json:"details,omitempty"`
}

// Pagination represents pagination information
type Pagination struct {
	Page     int  `json:"page"`
	Limit    int  `json:"limit"`
	Total    int64 `json:"total"`
	HasMore  bool `json:"hasMore"`
	NextPage *int `json:"nextPage,omitempty"`
}

// PaginatedResponse represents paginated API response
type PaginatedResponse struct {
	Success    bool        `json:"success"`
	Data       interface{} `json:"data"`
	Pagination Pagination  `json:"pagination"`
	Message    string      `json:"message,omitempty"`
}

// ==============================================================================
// REQUEST/RESPONSE DTOs
// ==============================================================================

// RegisterRequest represents user registration request
type RegisterRequest struct {
	Email       string `json:"email" binding:"required,email"`
	Password    string `json:"password" binding:"required,min=6"`
	FirstName   string `json:"firstName" binding:"required"`
	LastName    string `json:"lastName" binding:"required"`
	PhoneNumber string `json:"phoneNumber" binding:"required"`
}

// LoginRequest represents user login request
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse represents authentication response
type AuthResponse struct {
	ID       string `json:"id"`
	Email    string `json:"email"`
	Token    string `json:"token"`
	UserProfile User `json:"userProfile"`
}

// CreateOrderRequest represents create order request
type CreateOrderRequest struct {
	RestaurantID    string        `json:"restaurantId" binding:"required"`
	RestaurantName  string        `json:"restaurantName" binding:"required"`
	Items           []OrderItem   `json:"items" binding:"required,min=1"`
	Subtotal        float64       `json:"subtotal" binding:"required,min=0"`
	DeliveryFee     float64       `json:"deliveryFee" binding:"required,min=0"`
	Tax             float64       `json:"tax" binding:"required,min=0"`
	Total           float64       `json:"total" binding:"required,min=0"`
	DeliveryAddress string        `json:"deliveryAddress" binding:"required"`
	PaymentMethodID string        `json:"paymentMethodId" binding:"required"`
	Notes           *string       `json:"notes,omitempty"`
}

// UpdateOrderStatusRequest represents update order status request
type UpdateOrderStatusRequest struct {
	Status              OrderStatus `json:"status" binding:"required"`
	DeliveryPersonName  *string     `json:"deliveryPersonName,omitempty"`
	DeliveryPersonPhone *string     `json:"deliveryPersonPhone,omitempty"`
	TrackingURL         *string     `json:"trackingUrl,omitempty"`
}

// CreateAddressRequest represents create address request
type CreateAddressRequest struct {
	Street    string   `json:"street" binding:"required"`
	City      string   `json:"city" binding:"required"`
	State     string   `json:"state" binding:"required"`
	ZipCode   string   `json:"zipCode" binding:"required"`
	Type      string   `json:"type" binding:"required"`
	Address   string   `json:"address" binding:"required"`
	Apartment string   `json:"apartment" binding:"required"`
	Title     *string  `json:"title,omitempty"`
	Latitude  *float64 `json:"latitude,omitempty"`
	Longitude *float64 `json:"longitude,omitempty"`
	IsDefault bool     `json:"isDefault"`
}

// SendMessageRequest represents send message request
type SendMessageRequest struct {
	Content     string `json:"content" binding:"required"`
	MessageType string `json:"messageType"` // Default: "text"
}

// RestaurantSearchParams represents restaurant search parameters
type RestaurantSearchParams struct {
	Query    string  `form:"query"`
	Lat      float64 `form:"lat"`
	Lng      float64 `form:"lng"`
	Radius   float64 `form:"radius"` // in kilometers
	Category string  `form:"category"`
	MinRating float64 `form:"minRating"`
	IsOpen   *bool   `form:"isOpen"`
	Page     int     `form:"page" binding:"min=1"`
	Limit    int     `form:"limit" binding:"min=1,max=100"`
}

// FoodSearchParams represents food search parameters
type FoodSearchParams struct {
	Query        string  `form:"query"`
	Category     string  `form:"category"`
	RestaurantID string  `form:"restaurantId"`
	MinRating    float64 `form:"minRating"`
	MaxPrice     float64 `form:"maxPrice"`
	IsVegetarian *bool   `form:"isVegetarian"`
	IsVegan      *bool   `form:"isVegan"`
	IsGlutenFree *bool   `form:"isGlutenFree"`
	Page         int     `form:"page" binding:"min=1"`
	Limit        int     `form:"limit" binding:"min=1,max=100"`
}

// ==============================================================================
// COMPOSITE INDEX DEFINITIONS (for database migrations)
// ==============================================================================

/*
Recommended database indexes for optimal performance:

1. Users table:
   - email (unique index) - already defined in struct
   - phone_number (unique index)

2. Addresses table:
   - user_id (index) - already defined
   - (user_id, is_default) composite index
   - (latitude, longitude) spatial index

3. Restaurants table:
   - name (index) - already defined
   - (latitude, longitude) spatial index - already defined
   - rating (index)
   - is_open (index)

4. Foods table:
   - name (index) - already defined
   - restaurant_id (index) - already defined
   - category (index) - already defined
   - (restaurant_id, category) composite index
   - price (index)
   - rating (index)
   - is_available (index)

5. Orders table:
   - user_id (index) - already defined
   - restaurant_id (index) - already defined
   - status (index)
   - created_at (index)
   - (user_id, created_at) composite index

6. Messages table:
   - chat_id (index) - already defined
   - sender_id (index) - already defined
   - (chat_id, created_at) composite index
   - is_read (index)

7. Chats table:
   - sender_id (index) - already defined
   - receiver_id (index) - already defined
   - (sender_id, receiver_id) composite unique index

8. Notifications table:
   - user_id (index) - already defined
   - (user_id, created_at) composite index
   - is_read (index)

9. Favorite tables:
   - (user_id, food_id) composite unique index for FavoriteFood
   - (user_id, restaurant_id) composite unique index for FavoriteRestaurant
*/