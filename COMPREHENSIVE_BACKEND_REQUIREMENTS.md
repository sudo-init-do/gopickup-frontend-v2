# GoPickup Full Backend Requirements Specification

This document serves as the absolute blueprint for developing the GoPickup backend. It contains comprehensive details regarding the database schema, API endpoints, WebSocket events, and third-party integrations necessary to run the multi-role platform (Client, Driver, Vendor, Admin).

---

## 🏗 1. System Architecture & Tech Stack Recommendations

To build a highly scalable ecosystem, the following backend stack is recommended:

- **Framework Structure**: Node.js (Express/NestJS), Go (Fiber/Gin), or a Backend-as-a-Service like Supabase.
- **Database**: PostgreSQL (relational structure is required for orders, transactions, and users).
- **Real-time / WebSockets**: Socket.io (Node.js) or Supabase Realtime for live order tracking and chat.
- **File Storage**: AWS S3, Cloudinary, or Supabase Storage for storing avatars, vehicle documents, and product images.
- **Payments**: Flutterwave for robust sub-Saharan Africa payment features (Wallets, Cards, Bank Transfers).
- **Location Services**: Google Maps Platform (Places API, Distance Matrix API) or Mapbox for driver routing.

---

## 🗄 2. Database Schema (Entities & Relationships)

### 2.1 Users & Authentication

- `id` (UUID, Primary Key)
- `email` (String, Unique)
- `password_hash` (String)
- `role` (Enum: `client`, `driver`, `vendor`, `admin`)
- `is_verified` (Boolean) - Set to true after OTP verification
- `fcm_token` (String, Nullable) - For push notifications
- `created_at`, `updated_at` (Timestamps)

### 2.2 Profiles (One-to-One with Users)

**Client Profile**

- `user_id` (UUID, Foreign Key)
- `full_name` (String)
- `phone_number` (String, Unique)
- `address` (String)
- `profile_picture_url` (String, Nullable)

**Driver Profile**

- `user_id` (UUID, Foreign Key)
- `full_name` (String)
- `phone_number` (String, Unique)
- `license_number` (String, Unique)
- `vehicle_type` (Enum: `Tricycle`, `Van`, `Truck`, `Flatbed`, `Trailer`)
- `plate_number` (String, Unique)
- `vehicle_capacity` (String)
- `is_approved` (Boolean) - Admin approval status
- `current_location_lat` (Float, Nullable)
- `current_location_lng` (Float, Nullable)
- `profile_picture_url` (String, Nullable)

**Vendor Profile**

- `user_id` (UUID, Foreign Key)
- `store_name` (String)
- `business_type` (Enum: `Building Materials`, `Hardware`, `Electrical`, etc.)
- `address` (String)
- `store_banner_url` (String, Nullable)
- `is_approved` (Boolean)

### 2.3 Wallet & Transactions

**Wallets**

- `user_id` (UUID, Primary Key)
- `balance` (Decimal, default `0.00`)
- `currency` (String, default `NGN`)

**Transactions**

- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key)
- `amount` (Decimal)
- `type` (Enum: `deposit`, `withdrawal`, `payment`, `payout`)
- `reference` (String, Unique) - From Flutterwave or internal
- `status` (Enum: `pending`, `successful`, `failed`)
- `created_at` (Timestamp)

### 2.4 Marketplace (Products)

- `id` (UUID, Primary Key)
- `vendor_id` (UUID, Foreign Key)
- `name` (String)
- `description` (Text)
- `price` (Decimal)
- `category` (String)
- `stock_quantity` (Int)
- `image_url` (String)
- `is_active` (Boolean)
- `created_at`, `updated_at`

### 2.5 Orders & Logistics

**Orders**

- `id` (UUID, Primary Key)
- `client_id` (UUID, Foreign Key)
- `vendor_id` (UUID, Foreign Key)
- `driver_id` (UUID, Foreign Key, Nullable)
- `status` (Enum: `pending`, `processing`, `searching_driver`, `transit`, `delivered`, `cancelled`)
- `total_product_amount` (Decimal)
- `delivery_fee` (Decimal, Nullable)
- `pickup_address` (String)
- `delivery_address` (String)
- `delivery_lat` (Float)
- `delivery_lng` (Float)
- `payment_method` (Enum: `wallet`, `card`, `cash_on_delivery`)
- `created_at`, `updated_at`

**Order Items**

- `id` (UUID, Primary Key)
- `order_id` (UUID, Foreign Key)
- `product_id` (UUID, Foreign Key)
- `quantity` (Int)
- `price_at_time_of_purchase` (Decimal)

**Job Bids (Drivers bidding on Orders)**

- `id` (UUID, Primary Key)
- `order_id` (UUID, Foreign Key)
- `driver_id` (UUID, Foreign Key)
- `amount` (Decimal) - The driver's proposed fee
- `estimated_time` (String) - E.g. "45 mins"
- `status` (Enum: `pending`, `accepted`, `rejected`)
- `created_at`

### 2.6 Chat System

**Conversations**

- `id` (UUID, Primary Key)
- `participant_1_id` (UUID, Foreign Key)
- `participant_2_id` (UUID, Foreign Key)
- `order_id` (UUID, Foreign Key, Nullable) - Optional context
- `created_at`

**Messages**

- `id` (UUID, Primary Key)
- `conversation_id` (UUID, Foreign Key)
- `sender_id` (UUID, Foreign Key)
- `text` (Text)
- `is_read` (Boolean, default `false`)
- `created_at`

---

## 🚀 3. REST API Endpoints

All endpoints assume base URL: `/api/v1`

### Authentication & Identification (RBAC protected)

| Method | Endpoint                | Description                              | Public/Protected |
| :----- | :---------------------- | :--------------------------------------- | :--------------- |
| POST   | `/auth/register`        | Initial email/pass/role registration     | Public           |
| POST   | `/auth/verify-otp`      | Verify 6-digit OTP code                  | Public           |
| POST   | `/auth/login`           | Email/password login -> returns JWT      | Public           |
| POST   | `/auth/forgot-password` | Trigger password reset email/OTP         | Public           |
| POST   | `/auth/reset-password`  | Reset password using token               | Public           |
| GET    | `/auth/me`              | Get currently authenticated user details | Protected        |

### Profiles & Onboarding

| Method | Endpoint          | Description                              | Required Role |
| :----- | :---------------- | :--------------------------------------- | :------------ |
| POST   | `/profile/client` | Complete client profile                  | Client        |
| POST   | `/profile/driver` | Upload driver documents and vehicle info | Driver        |
| POST   | `/profile/vendor` | Setup store information                  | Vendor        |
| PUT    | `/profile`        | Generic update to current user's profile | Any           |

### Vendor Marketplace Operations

| Method | Endpoint               | Description                              | Required Role |
| :----- | :--------------------- | :--------------------------------------- | :------------ |
| POST   | `/vendor/products`     | Add new product to catalog               | Vendor        |
| PUT    | `/vendor/products/:id` | Update product details/stock             | Vendor        |
| DELETE | `/vendor/products/:id` | Remove a product                         | Vendor        |
| GET    | `/vendor/dashboard`    | Aggregated stats (sales, pending orders) | Vendor        |

### Discovery (Client & Public)

| Method | Endpoint        | Description                                | Security |
| :----- | :-------------- | :----------------------------------------- | :------- |
| GET    | `/products`     | Filterable, paginated products list        | Public   |
| GET    | `/products/:id` | Fetch single product details & vendor info | Public   |
| GET    | `/vendors`      | Filterable list of vendor stores           | Public   |

### Orders Lifecycle

| Method | Endpoint             | Description                                                   | Actors |
| :----- | :------------------- | :------------------------------------------------------------ | :----- |
| POST   | `/orders/checkout`   | Client creates an order from cart                             | Client |
| GET    | `/orders`            | List user's orders (vendor sees sales, client sees purchases) | All    |
| GET    | `/orders/:id`        | Get robust details of a single order                          | All    |
| PATCH  | `/orders/:id/status` | Vendor accepts (processing) or cancels                        | Vendor |

### Logistics & Driver Bidding System

| Method | Endpoint                          | Description                                         | Actors |
| :----- | :-------------------------------- | :-------------------------------------------------- | :----- |
| PATCH  | `/orders/:id/ready`               | Vendor marks order as "searching_driver"            | Vendor |
| GET    | `/jobs/available`                 | Drivers see list of local "searching_driver" orders | Driver |
| POST   | `/jobs/:order_id/bid`             | Driver casts a bid for delivery fee                 | Driver |
| GET    | `/orders/:id/bids`                | Client sees all received driver bids                | Client |
| POST   | `/orders/:id/bids/:bid_id/accept` | Client selects driver, order -> "transit"           | Client |

### Wallet & Payments

| Method | Endpoint           | Description                                 | Details       |
| :----- | :----------------- | :------------------------------------------ | :------------ |
| GET    | `/wallet/balance`  | View current balance                        | Protected     |
| POST   | `/wallet/fund`     | Generate Flutterwave payment link/reference | Protected     |
| POST   | `/wallet/webhook`  | Flutterwave Server-to-Server validation     | Public        |
| POST   | `/wallet/withdraw` | Request payout to local bank account        | Vendor/Driver |

### Chat

| Method | Endpoint              | Description                                      |
| :----- | :-------------------- | :----------------------------------------------- |
| GET    | `/chats`              | Get all active conversation threads for user     |
| GET    | `/chats/:id/messages` | Get message history for a thread                 |
| POST   | `/chats/initiate`     | Initiate new conversation (with a driver/client) |

---

## 📡 4. WebSockets / Real-Time Spec

For a logistics app, real-time is not a luxury, it's a necessity.

### Client-Side Socket Initialization

Requires authentication via JWT token passed into socket connection headers.

### Channels/Rooms

1. `user:{user_id}`: Private room for notifications pertaining only to this user.
2. `order:{order_id}`: Room for all actors (Client, Driver, Vendor) affiliated with this order to receive live updates.
3. `chat:{chat_id}`: Dedicated room for real-time messaging latency reduction.

### Expected Events (Emitted from Client -> Server)

- `driver_location_update`: Driver app emits `{ lat: X, lng: Y, order_id: Z }` every 10 seconds while in transit.
- `chat_message`: User emits `{ chat_id: A, text: "Hello" }`.

### Expected Events (Emitted from Server -> Client)

- `order_status_updated`: Server pushes `{ status: 'processing', timestamp: ... }` to `order:{order_id}`.
- `new_bid`: Server pushes `{ bid_amount: 3000, driver_name: "John", rating: 4.5 }` to `user:{client_id}`.
- `bid_accepted`: Server pushes notification to Driver's room `user:{driver_id}` to proceed to vendor.
- `driver_moved`: Server pushes the driver's coordinates continuously to the mapping client tracking the order.
- `new_message`: Pushed to recipient's `user:{user_id}` room to trigger push notification or UI update.

---

## 🔐 5. Security & Infrastructure Policies

1. **Idempotency**: All payment endpoints (`/wallet/fund` and webhook) must handle duplicate requests gracefully using reference checks to prevent double crediting.
2. **Geospatial Queries**: Use PostGIS (if PostgreSQL) to calculate distance radiuses efficiently when querying `/jobs/available` for drivers.
3. **FCM (Firebase Cloud Messaging)**: Use WebSockets when the app is foregrounded, but ALWAYS broadcast an FCM Push Notification alongside WebSocket events so users get notified if the app is closed.
4. **Environment Variables Needed**:
   - `DATABASE_URL`
   - `JWT_SECRET_KEY`
   - `FLUTTERWAVE_SECRET_KEY`
   - `FLUTTERWAVE_WEBHOOK_HASH`
   - `AWS_S3_BUCKET` / `CLOUDINARY_URL`
   - `GOOGLE_MAPS_API_KEY`
