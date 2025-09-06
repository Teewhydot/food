package models

import (
	"time"
	"database/sql/driver"
	"encoding/json"
	"errors"
)

// MariaDB-optimized Golang models for Food Delivery App
// This file contains all entity models specifically optimized for MariaDB features

// ==============================================================================
// CUSTOM TYPES FOR MARIADB
// ==============================================================================

// StringArray is a custom type for handling string arrays in MariaDB JSON columns
type StringArray []string

func (sa StringArray) Value() (driver.Value, error) {
	if len(sa) == 0 {
		return "[]", nil
	}
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

// ==============================================================================
// AUTHENTICATION & USER MODELS
// ==============================================================================

// User represents the main user entity - MariaDB optimized
type User struct {
	ID               string    `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	FirstName        string    `json:"firstName" gorm:"column:first_name;type:varchar(100);not null"`
	LastName         string    `json:"lastName" gorm:"column:last_name;type:varchar(100);not null"`
	Email            string    `json:"email" gorm:"column:email;type:varchar(255);uniqueIndex:idx_users_email;not null"`
	PhoneNumber      string    `json:"phoneNumber" gorm:"column:phone_number;type:varchar(20);not null;index:idx_users_phone"`
	PasswordHash     string    `json:"-" gorm:"column:password_hash;type:varchar(255);not null"`
	ProfileImageURL  *string   `json:"profileImageUrl,omitempty" gorm:"column:profile_image_url;type:text"`
	Bio              *string   `json:"bio,omitempty" gorm:"column:bio;type:text"`
	FirstTimeLogin   bool      `json:"firstTimeLogin" gorm:"column:first_time_login;type:tinyint(1);default:1"`
	EmailVerified    bool      `json:"emailVerified" gorm:"column:email_verified;type:tinyint(1);default:0"`
	IsActive         bool      `json:"isActive" gorm:"column:is_active;type:tinyint(1);default:1"`
	FCMToken         *string   `json:"fcmToken,omitempty" gorm:"column:fcm_token;type:text"`
	CreatedAt        time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt        time.Time `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
}

// TableName returns the table name for User model
func (User) TableName() string {
	return "users"
}

// Address represents user address entity - MariaDB optimized
type Address struct {
	ID        string   `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	UserID    string   `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index:idx_addresses_user_id"`
	Street    string   `json:"street" gorm:"column:street;type:varchar(255);not null"`
	City      string   `json:"city" gorm:"column:city;type:varchar(100);not null;index:idx_addresses_city"`
	State     string   `json:"state" gorm:"column:state;type:varchar(100);not null"`
	ZipCode   string   `json:"zipCode" gorm:"column:zip_code;type:varchar(20);not null"`
	Type      string   `json:"type" gorm:"column:type;type:enum('home','work','other');default:'home'"`
	Address   string   `json:"address" gorm:"column:address;type:varchar(500);not null"`
	Apartment string   `json:"apartment" gorm:"column:apartment;type:varchar(100);not null"`
	Title     *string  `json:"title,omitempty" gorm:"column:title;type:varchar(100)"`
	Latitude  *float64 `json:"latitude,omitempty" gorm:"column:latitude;type:decimal(10,8)"`
	Longitude *float64 `json:"longitude,omitempty" gorm:"column:longitude;type:decimal(11,8)"`
	IsDefault bool     `json:"isDefault" gorm:"column:is_default;type:tinyint(1);default:0;index:idx_addresses_user_default"`
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt time.Time `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	
	// Relationships
	User      User     `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for Address model
func (Address) TableName() string {
	return "addresses"
}

// Permission represents permission entity - MariaDB optimized
type Permission struct {
	ID             uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID         string    `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index:idx_permissions_user_id"`
	PermissionName string    `json:"permissionName" gorm:"column:permission_name;type:varchar(100);not null"`
	IsGranted      bool      `json:"isGranted" gorm:"column:is_granted;type:tinyint(1);not null;default:0"`
	CreatedAt      time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt      time.Time `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	
	// Relationships
	User           User      `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for Permission model
func (Permission) TableName() string {
	return "permissions"
}

// ==============================================================================
// RESTAURANT MODELS
// ==============================================================================

// Restaurant represents the restaurant entity - MariaDB optimized
type Restaurant struct {
	ID           string      `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	Name         string      `json:"name" gorm:"column:name;type:varchar(255);not null;index:idx_restaurants_name"`
	Description  string      `json:"description" gorm:"column:description;type:text;not null"`
	Location     string      `json:"location" gorm:"column:location;type:varchar(500);not null"`
	Distance     float64     `json:"distance" gorm:"column:distance;type:decimal(8,2);default:0.00"`
	Rating       float64     `json:"rating" gorm:"column:rating;type:decimal(3,2);default:0.00;index:idx_restaurants_rating"`
	DeliveryTime string      `json:"deliveryTime" gorm:"column:delivery_time;type:varchar(50);not null"`
	DeliveryFee  float64     `json:"deliveryFee" gorm:"column:delivery_fee;type:decimal(8,2);not null"`
	ImageURL     string      `json:"imageUrl" gorm:"column:image_url;type:text;not null"`
	Categories   StringArray `json:"categories" gorm:"column:categories;type:json"`
	IsOpen       bool        `json:"isOpen" gorm:"column:is_open;type:tinyint(1);default:1;index:idx_restaurants_open"`
	Latitude     float64     `json:"latitude" gorm:"column:latitude;type:decimal(10,8);not null"`
	Longitude    float64     `json:"longitude" gorm:"column:longitude;type:decimal(11,8);not null"`
	CreatedAt    time.Time   `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt    time.Time   `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	
	// Relationships
	Foods        []Food                     `json:"foods,omitempty" gorm:"foreignKey:RestaurantID"`
	FoodCategories []RestaurantFoodCategory `json:"foodCategories,omitempty" gorm:"foreignKey:RestaurantID"`
}

// TableName returns the table name for Restaurant model
func (Restaurant) TableName() string {
	return "restaurants"
}

// RestaurantFoodCategory represents food categories within a restaurant - MariaDB optimized
type RestaurantFoodCategory struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	RestaurantID string    `json:"restaurantId" gorm:"column:restaurant_id;type:varchar(36);not null;index:idx_restaurant_categories_restaurant"`
	Category     string    `json:"category" gorm:"column:category;type:varchar(100);not null"`
	ImageURL     string    `json:"imageUrl" gorm:"column:image_url;type:text;not null"`
	CreatedAt    time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	
	// Relationships
	Restaurant   Restaurant `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Foods        []Food     `json:"foods,omitempty" gorm:"foreignKey:RestaurantID,Category;references:RestaurantID,Category"`
}

// TableName returns the table name for RestaurantFoodCategory model
func (RestaurantFoodCategory) TableName() string {
	return "restaurant_food_categories"
}

// ==============================================================================
// FOOD MODELS
// ==============================================================================

// Food represents the food entity - MariaDB optimized
type Food struct {
	ID              string      `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	Name            string      `json:"name" gorm:"column:name;type:varchar(255);not null;index:idx_foods_name"`
	Description     string      `json:"description" gorm:"column:description;type:text;not null"`
	Price           float64     `json:"price" gorm:"column:price;type:decimal(10,2);not null;index:idx_foods_price"`
	Rating          float64     `json:"rating" gorm:"column:rating;type:decimal(3,2);default:0.00;index:idx_foods_rating"`
	ImageURL        string      `json:"imageUrl" gorm:"column:image_url;type:text;not null"`
	Category        string      `json:"category" gorm:"column:category;type:varchar(100);not null;index:idx_foods_category"`
	RestaurantID    string      `json:"restaurantId" gorm:"column:restaurant_id;type:varchar(36);not null;index:idx_foods_restaurant"`
	RestaurantName  string      `json:"restaurantName" gorm:"column:restaurant_name;type:varchar(255);not null"`
	Ingredients     StringArray `json:"ingredients" gorm:"column:ingredients;type:json"`
	IsAvailable     bool        `json:"isAvailable" gorm:"column:is_available;type:tinyint(1);default:1;index:idx_foods_available"`
	PreparationTime string      `json:"preparationTime" gorm:"column:preparation_time;type:varchar(50);default:''"`
	Calories        int         `json:"calories" gorm:"column:calories;type:int unsigned;default:0"`
	Quantity        int         `json:"quantity" gorm:"column:quantity;type:int unsigned;default:1"`
	IsVegetarian    bool        `json:"isVegetarian" gorm:"column:is_vegetarian;type:tinyint(1);default:0;index:idx_foods_vegetarian"`
	IsVegan         bool        `json:"isVegan" gorm:"column:is_vegan;type:tinyint(1);default:0;index:idx_foods_vegan"`
	IsGlutenFree    bool        `json:"isGlutenFree" gorm:"column:is_gluten_free;type:tinyint(1);default:0;index:idx_foods_gluten_free"`
	CreatedAt       time.Time   `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt       time.Time   `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	
	// Relationships
	Restaurant      Restaurant  `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for Food model
func (Food) TableName() string {
	return "foods"
}

// ==============================================================================
// ORDER & PAYMENT MODELS
// ==============================================================================

// OrderStatus represents order status enum - MariaDB optimized
type OrderStatus string

const (
	OrderStatusPending   OrderStatus = "pending"
	OrderStatusConfirmed OrderStatus = "confirmed"
	OrderStatusPreparing OrderStatus = "preparing"
	OrderStatusOnTheWay  OrderStatus = "on_the_way"
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

// OrderItemsArray is a custom type for handling order items array in MariaDB JSON
type OrderItemsArray []OrderItem

func (oia OrderItemsArray) Value() (driver.Value, error) {
	if len(oia) == 0 {
		return "[]", nil
	}
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

// Order represents the order entity - MariaDB optimized
type Order struct {
	ID                   string          `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	UserID               string          `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index:idx_orders_user"`
	RestaurantID         string          `json:"restaurantId" gorm:"column:restaurant_id;type:varchar(36);not null;index:idx_orders_restaurant"`
	RestaurantName       string          `json:"restaurantName" gorm:"column:restaurant_name;type:varchar(255);not null"`
	Items                OrderItemsArray `json:"items" gorm:"column:items;type:json;not null"`
	Subtotal             float64         `json:"subtotal" gorm:"column:subtotal;type:decimal(10,2);not null"`
	DeliveryFee          float64         `json:"deliveryFee" gorm:"column:delivery_fee;type:decimal(8,2);not null"`
	Tax                  float64         `json:"tax" gorm:"column:tax;type:decimal(8,2);not null"`
	Total                float64         `json:"total" gorm:"column:total;type:decimal(10,2);not null"`
	DeliveryAddress      string          `json:"deliveryAddress" gorm:"column:delivery_address;type:text;not null"`
	PaymentMethod        string          `json:"paymentMethod" gorm:"column:payment_method;type:varchar(100);not null"`
	Status               OrderStatus     `json:"status" gorm:"column:status;type:enum('pending','confirmed','preparing','on_the_way','delivered','cancelled');default:'pending';index:idx_orders_status"`
	DeliveryPersonName   *string         `json:"deliveryPersonName,omitempty" gorm:"column:delivery_person_name;type:varchar(255)"`
	DeliveryPersonPhone  *string         `json:"deliveryPersonPhone,omitempty" gorm:"column:delivery_person_phone;type:varchar(20)"`
	TrackingURL          *string         `json:"trackingUrl,omitempty" gorm:"column:tracking_url;type:text"`
	Notes                *string         `json:"notes,omitempty" gorm:"column:notes;type:text"`
	CreatedAt            time.Time       `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP;index:idx_orders_created"`
	UpdatedAt            time.Time       `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	DeliveredAt          *time.Time      `json:"deliveredAt,omitempty" gorm:"column:delivered_at;type:timestamp null"`
	
	// Relationships
	User                 User            `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Restaurant           Restaurant      `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT"`
}

// TableName returns the table name for Order model
func (Order) TableName() string {
	return "orders"
}

// PaymentMethod represents payment method entity - MariaDB optimized
type PaymentMethod struct {
	ID          string    `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	Name        string    `json:"name" gorm:"column:name;type:varchar(100);not null"`
	Type        string    `json:"type" gorm:"column:type;type:enum('card','wallet','cash','bank_transfer');not null"`
	IconURL     string    `json:"iconUrl" gorm:"column:icon_url;type:text;not null"`
	IsActive    bool      `json:"isActive" gorm:"column:is_active;type:tinyint(1);default:1"`
	CreatedAt   time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
}

// TableName returns the table name for PaymentMethod model
func (PaymentMethod) TableName() string {
	return "payment_methods"
}

// Card represents payment card entity - MariaDB optimized
type Card struct {
	ID                   string        `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	UserID               string        `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index:idx_cards_user"`
	PaymentMethodID      string        `json:"paymentMethodId" gorm:"column:payment_method_id;type:varchar(36);not null"`
	LastFourDigits       string        `json:"lastFourDigits" gorm:"column:last_four_digits;type:varchar(4);not null"`
	CardToken            string        `json:"-" gorm:"column:card_token;type:text;not null"` // Tokenized card data
	ExpiryMonth          int           `json:"mExp" gorm:"column:expiry_month;type:tinyint unsigned;not null"`
	ExpiryYear           int           `json:"yExp" gorm:"column:expiry_year;type:smallint unsigned;not null"`
	CardholderName       string        `json:"cardholderName" gorm:"column:cardholder_name;type:varchar(255);not null"`
	CardType             string        `json:"cardType" gorm:"column:card_type;type:enum('visa','mastercard','amex','discover','other');not null"`
	IsDefault            bool          `json:"isDefault" gorm:"column:is_default;type:tinyint(1);default:0"`
	IsActive             bool          `json:"isActive" gorm:"column:is_active;type:tinyint(1);default:1"`
	CreatedAt            time.Time     `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt            time.Time     `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	
	// Relationships
	User                 User          `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	PaymentMethod        PaymentMethod `json:"paymentMethod,omitempty" gorm:"foreignKey:PaymentMethodID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT"`
}

// TableName returns the table name for Card model
func (Card) TableName() string {
	return "cards"
}

// PaymentTransaction represents payment transaction entity - MariaDB optimized
type PaymentTransaction struct {
	ID                string      `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	OrderID           string      `json:"orderId" gorm:"column:order_id;type:varchar(36);not null;index:idx_payment_transactions_order"`
	UserID            string      `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index:idx_payment_transactions_user"`
	PaymentMethodID   string      `json:"paymentMethodId" gorm:"column:payment_method_id;type:varchar(36);not null"`
	Amount            float64     `json:"amount" gorm:"column:amount;type:decimal(10,2);not null"`
	Currency          string      `json:"currency" gorm:"column:currency;type:varchar(3);default:'USD';not null"`
	Status            string      `json:"status" gorm:"column:status;type:enum('pending','processing','completed','failed','refunded','cancelled');not null;index:idx_payment_transactions_status"`
	GatewayTransactionID *string  `json:"gatewayTransactionId,omitempty" gorm:"column:gateway_transaction_id;type:varchar(255);uniqueIndex:idx_gateway_transaction"`
	FailureReason     *string     `json:"failureReason,omitempty" gorm:"column:failure_reason;type:text"`
	ProcessedAt       *time.Time  `json:"processedAt,omitempty" gorm:"column:processed_at;type:timestamp null"`
	CreatedAt         time.Time   `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt         time.Time   `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	
	// Relationships
	Order             Order       `json:"order,omitempty" gorm:"foreignKey:OrderID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	User              User        `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for PaymentTransaction model
func (PaymentTransaction) TableName() string {
	return "payment_transactions"
}

// ==============================================================================
// CHAT & MESSAGING MODELS
// ==============================================================================

// Chat represents chat entity - MariaDB optimized
type Chat struct {
	ID              string    `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	SenderID        string    `json:"senderId" gorm:"column:sender_id;type:varchar(36);not null;index:idx_chats_sender"`
	ReceiverID      string    `json:"receiverId" gorm:"column:receiver_id;type:varchar(36);not null;index:idx_chats_receiver"`
	OrderID         *string   `json:"orderId,omitempty" gorm:"column:order_id;type:varchar(36);index:idx_chats_order"`
	Name            string    `json:"name" gorm:"column:name;type:varchar(255);not null"`
	LastMessage     string    `json:"lastMessage" gorm:"column:last_message;type:text;default:''"`
	ImageURL        string    `json:"imageUrl" gorm:"column:image_url;type:text;default:''"`
	LastMessageTime time.Time `json:"lastMessageTime" gorm:"column:last_message_time;type:timestamp;default:CURRENT_TIMESTAMP"`
	CreatedAt       time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	UpdatedAt       time.Time `json:"updatedAt" gorm:"column:updated_at;type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"`
	
	// Relationships
	Sender          User      `json:"sender,omitempty" gorm:"foreignKey:SenderID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Receiver        User      `json:"receiver,omitempty" gorm:"foreignKey:ReceiverID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Order           *Order    `json:"order,omitempty" gorm:"foreignKey:OrderID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL"`
	Messages        []Message `json:"messages,omitempty" gorm:"foreignKey:ChatID"`
}

// TableName returns the table name for Chat model
func (Chat) TableName() string {
	return "chats"
}

// Message represents message entity - MariaDB optimized
type Message struct {
	ID         string    `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	ChatID     string    `json:"chatId" gorm:"column:chat_id;type:varchar(36);not null;index:idx_messages_chat"`
	Content    string    `json:"content" gorm:"column:content;type:text;not null"`
	SenderID   string    `json:"senderId" gorm:"column:sender_id;type:varchar(36);not null;index:idx_messages_sender"`
	ReceiverID string    `json:"receiverId" gorm:"column:receiver_id;type:varchar(36);not null;index:idx_messages_receiver"`
	IsRead     bool      `json:"isRead" gorm:"column:is_read;type:tinyint(1);default:0;index:idx_messages_read"`
	MessageType string   `json:"messageType" gorm:"column:message_type;type:enum('text','image','file','system');default:'text'"`
	FileURL     *string   `json:"fileUrl,omitempty" gorm:"column:file_url;type:text"`
	CreatedAt   time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP;index:idx_messages_created"`
	
	// Relationships
	Chat        Chat      `json:"chat,omitempty" gorm:"foreignKey:ChatID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Sender      User      `json:"sender,omitempty" gorm:"foreignKey:SenderID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Receiver    User      `json:"receiver,omitempty" gorm:"foreignKey:ReceiverID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for Message model
func (Message) TableName() string {
	return "messages"
}

// ==============================================================================
// NOTIFICATION MODELS
// ==============================================================================

// Notification represents notification entity - MariaDB optimized
type Notification struct {
	ID        string    `json:"id" gorm:"primaryKey;column:id;type:varchar(36)"`
	UserID    string    `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index:idx_notifications_user"`
	Title     string    `json:"title" gorm:"column:title;type:varchar(255);not null"`
	Body      string    `json:"body" gorm:"column:body;type:text;not null"`
	Type      string    `json:"type" gorm:"column:type;type:enum('order','promotion','system','chat','general');not null;index:idx_notifications_type"`
	IsRead    bool      `json:"isRead" gorm:"column:is_read;type:tinyint(1);default:0;index:idx_notifications_read"`
	Data      *string   `json:"data,omitempty" gorm:"column:data;type:json"` // Additional data as JSON
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP;index:idx_notifications_created"`
	
	// Relationships
	User      User      `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for Notification model
func (Notification) TableName() string {
	return "notifications"
}

// ==============================================================================
// FAVORITES MODELS
// ==============================================================================

// FavoriteFood represents favorite food entity - MariaDB optimized
type FavoriteFood struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    string    `json:"userId" gorm:"column:user_id;type:varchar(36);not null"`
	FoodID    string    `json:"foodId" gorm:"column:food_id;type:varchar(36);not null"`
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	
	// Relationships
	User      User      `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Food      Food      `json:"food,omitempty" gorm:"foreignKey:FoodID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for FavoriteFood model
func (FavoriteFood) TableName() string {
	return "favorite_foods"
}

// FavoriteRestaurant represents favorite restaurant entity - MariaDB optimized
type FavoriteRestaurant struct {
	ID           uint       `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       string     `json:"userId" gorm:"column:user_id;type:varchar(36);not null"`
	RestaurantID string     `json:"restaurantId" gorm:"column:restaurant_id;type:varchar(36);not null"`
	CreatedAt    time.Time  `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	
	// Relationships
	User         User       `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Restaurant   Restaurant `json:"restaurant,omitempty" gorm:"foreignKey:RestaurantID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for FavoriteRestaurant model
func (FavoriteRestaurant) TableName() string {
	return "favorite_restaurants"
}

// ==============================================================================
// SEARCH & UTILITY MODELS
// ==============================================================================

// RecentKeyword represents recent search keyword entity - MariaDB optimized
type RecentKeyword struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    string    `json:"userId" gorm:"column:user_id;type:varchar(36);not null;index:idx_recent_keywords_user"`
	Keyword   string    `json:"keyword" gorm:"column:keyword;type:varchar(255);not null;index:idx_recent_keywords_keyword"`
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;type:timestamp;default:CURRENT_TIMESTAMP"`
	
	// Relationships
	User      User      `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

// TableName returns the table name for RecentKeyword model
func (RecentKeyword) TableName() string {
	return "recent_keywords"
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
	Page     int   `json:"page"`
	Limit    int   `json:"limit"`
	Total    int64 `json:"total"`
	HasMore  bool  `json:"hasMore"`
	NextPage *int  `json:"nextPage,omitempty"`
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
	Password    string `json:"password" binding:"required,min=8"`
	FirstName   string `json:"firstName" binding:"required,min=2,max=100"`
	LastName    string `json:"lastName" binding:"required,min=2,max=100"`
	PhoneNumber string `json:"phoneNumber" binding:"required,min=10,max=20"`
}

// LoginRequest represents user login request
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse represents authentication response
type AuthResponse struct {
	ID          string `json:"id"`
	Email       string `json:"email"`
	Token       string `json:"token"`
	RefreshToken string `json:"refreshToken"`
	UserProfile User   `json:"userProfile"`
}

// CreateOrderRequest represents create order request
type CreateOrderRequest struct {
	RestaurantID    string      `json:"restaurantId" binding:"required"`
	RestaurantName  string      `json:"restaurantName" binding:"required"`
	Items           []OrderItem `json:"items" binding:"required,min=1,dive"`
	Subtotal        float64     `json:"subtotal" binding:"required,min=0"`
	DeliveryFee     float64     `json:"deliveryFee" binding:"required,min=0"`
	Tax             float64     `json:"tax" binding:"required,min=0"`
	Total           float64     `json:"total" binding:"required,min=0"`
	DeliveryAddress string      `json:"deliveryAddress" binding:"required"`
	PaymentMethodID string      `json:"paymentMethodId" binding:"required"`
	Notes           *string     `json:"notes,omitempty"`
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
	Type      string   `json:"type" binding:"required,oneof=home work other"`
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
	MessageType string `json:"messageType" binding:"oneof=text image file system"`
}

// RestaurantSearchParams represents restaurant search parameters
type RestaurantSearchParams struct {
	Query     string  `form:"query"`
	Lat       float64 `form:"lat"`
	Lng       float64 `form:"lng"`
	Radius    float64 `form:"radius"` // in kilometers
	Category  string  `form:"category"`
	MinRating float64 `form:"minRating" binding:"min=0,max=5"`
	IsOpen    *bool   `form:"isOpen"`
	Page      int     `form:"page" binding:"min=1"`
	Limit     int     `form:"limit" binding:"min=1,max=100"`
}

// FoodSearchParams represents food search parameters
type FoodSearchParams struct {
	Query        string  `form:"query"`
	Category     string  `form:"category"`
	RestaurantID string  `form:"restaurantId"`
	MinRating    float64 `form:"minRating" binding:"min=0,max=5"`
	MaxPrice     float64 `form:"maxPrice" binding:"min=0"`
	IsVegetarian *bool   `form:"isVegetarian"`
	IsVegan      *bool   `form:"isVegan"`
	IsGlutenFree *bool   `form:"isGlutenFree"`
	Page         int     `form:"page" binding:"min=1"`
	Limit        int     `form:"limit" binding:"min=1,max=100"`
}

// ==============================================================================
// MARIADB SPECIFIC CONFIGURATIONS AND INDEXES
// ==============================================================================

/*
MariaDB-specific optimizations and recommended configurations:

1. Engine Configuration:
   - Use InnoDB engine for all tables (default in modern MariaDB)
   - Enable innodb_file_per_table = ON
   - Set appropriate innodb_buffer_pool_size (70-80% of available RAM)

2. Spatial Indexes (for geolocation):
   CREATE SPATIAL INDEX idx_restaurants_location ON restaurants (POINT(longitude, latitude));
   CREATE SPATIAL INDEX idx_addresses_location ON addresses (POINT(longitude, latitude));

3. Full-text Indexes (for search):
   CREATE FULLTEXT INDEX idx_restaurants_search ON restaurants (name, description);
   CREATE FULLTEXT INDEX idx_foods_search ON foods (name, description);

4. Composite Indexes:
   CREATE INDEX idx_favorite_foods_unique ON favorite_foods (user_id, food_id);
   CREATE INDEX idx_favorite_restaurants_unique ON favorite_restaurants (user_id, restaurant_id);
   CREATE INDEX idx_orders_user_status ON orders (user_id, status, created_at);
   CREATE INDEX idx_messages_chat_created ON messages (chat_id, created_at DESC);
   CREATE INDEX idx_notifications_user_read ON notifications (user_id, is_read, created_at DESC);

5. JSON Indexes (MariaDB 10.3+):
   CREATE INDEX idx_restaurants_categories ON restaurants ((JSON_EXTRACT(categories, '$')));
   CREATE INDEX idx_foods_ingredients ON foods ((JSON_EXTRACT(ingredients, '$')));

6. Partitioning Strategy:
   - Consider partitioning large tables like orders, messages, notifications by date
   - Example: PARTITION BY RANGE (YEAR(created_at))

7. Character Set:
   - Use utf8mb4 for full Unicode support
   - Set utf8mb4_unicode_ci collation

8. Connection Configuration:
   - max_connections = 200-500 (depending on server capacity)
   - max_user_connections = 100
   - thread_cache_size = 50-100

9. Query Cache (if using older MariaDB versions):
   - query_cache_type = ON
   - query_cache_size = 128M

10. Recommended my.cnf settings:
    [mysqld]
    default-storage-engine = InnoDB
    character-set-server = utf8mb4
    collation-server = utf8mb4_unicode_ci
    innodb_buffer_pool_size = 2G  # Adjust based on available RAM
    innodb_log_file_size = 256M
    innodb_flush_log_at_trx_commit = 2
    innodb_file_per_table = ON
    max_connections = 300
    thread_cache_size = 100
    query_cache_type = ON
    query_cache_size = 128M
*/