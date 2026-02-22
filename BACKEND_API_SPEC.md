# GoPickup Backend API Specification v2.0

This document provides a detailed technical specification for the GoPickup REST API.

## 📌 General Information
- **Base URL**: `https://api.gopickup.com/api/v1`
- **Content-Type**: `application/json`
- **Authentication**: Bearer Token (JWT)

---

## 🔐 Authentication & Onboarding

### POST `/auth/register`
Initial user registration.
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "SecurePassword123",
    "role": "client" | "driver" | "vendor"
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "message": "Registration successful. Please verify your OTP.",
    "userId": "uuid-string"
  }
  ```

### POST `/auth/verify-otp`
- **Request Body**: `{ "email": "user@example.com", "code": "123456" }`
- **Response (200 OK)**:
  ```json
  {
    "token": "eyJhbGci...",
    "user": { "id": "uuid", "email": "user@example.com", "role": "client" }
  }
  ```

### POST `/auth/onboarding/complete`
Used to set profile details based on the user role.
- **Headers**: `Authorization: Bearer <token>`
- **Request Body (Client)**:
  ```json
  {
    "fullName": "John Doe",
    "phoneNumber": "+2348000000000",
    "address": "123 Green St",
    "city": "Lagos"
  }
  ```
- **Request Body (Driver)**:
  ```json
  {
    "licenseNo": "ABC-12345",
    "vehicleType": "Van",
    "plateNo": "LND-789-XY",
    "vehicleCapacity": "1.5 tons"
  }
  ```
- **Request Body (Vendor)**:
  ```json
  {
    "storeName": "BuildMart Supplies",
    "businessType": "Hardware",
    "address": "45 Industrial Ave",
    "landmark": "Near Central Bank"
  }
  ```

---

## 🛒 Marketplace & Catalog

### GET `/products`
Retrieve a paginated list of products.
- **Query Params**:
  - `q`: Search keyword (string)
  - `category`: Filter by category (enum)
  - `minPrice`: Minimum price (float)
  - `maxPrice`: Maximum price (float)
  - `page`: Page number (default: 1)
  - `limit`: Items per page (default: 20)
- **Response**:
  ```json
  {
    "total": 150,
    "page": 1,
    "items": [
      {
        "id": "prod-1",
        "name": "Dangote Cement 50kg",
        "price": 5000.0,
        "category": "Building Materials",
        "imageUrl": "https://cdn...",
        "vendor": { "id": "v-1", "name": "BuildMart" }
      }
    ]
  }
  ```

### GET `/products/:id`
Fetch full product details including technical specs and vendor info.

---

## 📦 Orders & Logistics

### POST `/orders/checkout`
Create a new order from the client's cart.
- **Request Body**:
  ```json
  {
    "items": [
      { "productId": "prod-1", "quantity": 10 }
    ],
    "deliveryAddress": "123 Green St",
    "paymentMethod": "wallet" | "card"
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "orderId": "ORD-789",
    "totalAmount": 50000.0,
    "status": "pending"
  }
  ```

### GET `/jobs/available` (For Drivers)
Fetch loads waiting for delivery within the driver's service area.
- **Response**:
  ```json
  [
    {
      "id": "job-101",
      "pickupAddress": "45 Industrial Ave",
      "deliveryAddress": "123 Green St",
      "distance": "12.5 km",
      "weight": "500 kg",
      "suggestedPrice": 2500.0
    }
  ]
  ```

### POST `/jobs/:id/bid` (For Drivers)
Submit a bid for a delivery job.
- **Request Body**:
  ```json
  {
    "amount": 2200.0,
    "estimatedPickupTime": "20 mins",
    "estimatedDeliveryTime": "45 mins"
  }
  ```

---

## 🏪 Vendor Operations

### GET `/vendor/dashboard`
Aggregated sales data for the vendor home screen.
- **Response**:
  ```json
  {
    "totalRevenue": 12400.0,
    "ordersToday": 5,
    "productsActive": 24,
    "profileViews": 2300
  }
  ```

### POST `/vendor/products`
Add a new item to the store.
- **Request Body**:
  ```json
  {
    "name": "Steel Rod 12mm",
    "description": "High-tensile steel...",
    "price": 8500.0,
    "category": "Building Materials",
    "stock": 500,
    "image": "base64_string_or_multipart"
  }
  ```

---

## 💬 Real-time & Shared Services

### GET `/chats`
Returns a list of conversations.

### GET `/chats/:id/messages`
Paginated history of messages in a thread.

### WebSocket `/socket` (Real-time)
- **Events**:
  - `new_message`: Notify recipient of a chat message.
  - `location_update`: Sent by drivers during transit.
  - `order_update`: Notify client when status changes to `transit`.

---

## ⚠️ Error Codes
| Code | Meaning | Description |
| :--- | :--- | :--- |
| `400` | Bad Request | Validation failed (e.g., missing fields) |
| `401` | Unauthorized | Missing or invalid Bearer token |
| `403` | Forbidden | User role does not have permission for this action |
| `404` | Not Found | Resource (product/order) does not exist |
| `429` | Too Many Requests | Rate limit exceeded (OTP) |
| `500` | Server Error | Internal backend crash |

---

## 🏗 Data Enums

### Order Status Flow
1. `pending`: Waiting for vendor acceptance.
2. `processing`: Vendor packaging items.
3. `searching_driver`: Looking for a delivery partner.
4. `transit`: Driver is on the way.
5. `delivered`: Job completed.

### Vehicle Types
- `Tricycle` | `Van` | `Trucks` | `Flatbeds` | `Trailer`

### Product Categories
- `Building Materials` | `Electrical Supplies` | `Plumbing` | `Hardware` | `Paint & Finishes` | `Lumber`
