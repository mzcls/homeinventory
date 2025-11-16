# Home Inventory API Documentation

## Base URL

`http://127.0.0.1:8000`

## Response Format

All API responses follow a unified format:

```json
{
  "status": "success" | "error",
  "data": {}, // The actual response data
  "message": "" // A descriptive message
}
```

## Authentication

Authentication is handled using JWT (JSON Web Tokens). To access protected endpoints, you must include an `Authorization` header with the value `Bearer <your_token>`.

---

## Auth Module

**Prefix:** `/auth`

### 1. Register User

*   **Endpoint:** `POST /auth/register`
*   **Description:** Registers a new user.
*   **Request Body:**
    ```json
    {
      "username": "string",
      "email": "user@example.com",
      "password": "string"
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": {
        "username": "string",
        "email": "user@example.com",
        "user_id": 1
      },
      "message": "User registered successfully"
    }
    ```
*   **Error Response (400 Bad Request):**
    *   If email is already registered.
    *   If username is already taken.

### 2. Login for Access Token

*   **Endpoint:** `POST /auth/token`
*   **Description:** Logs in a user and returns a JWT access token.
*   **Request Body:** `x-www-form-urlencoded`
    *   `username`: your_username
    *   `password`: your_password
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": {
        "access_token": "string",
        "token_type": "bearer"
      },
      "message": "Login successful"
    }
    ```
*   **Error Response (401 Unauthorized):**
    *   If username or password is incorrect.

### 3. Get Current User Info

*   **Endpoint:** `GET /auth/users/me`
*   **Description:** Retrieves information about the currently authenticated user.
*   **Authentication:** Required.
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": {
        "username": "string",
        "email": "user@example.com",
        "user_id": 1
      },
      "message": "User information retrieved successfully"
    }
    ```

---

## Warehouses Module

**Prefix:** `/warehouses`
**Authentication:** Required for all endpoints.

### 1. Create Warehouse

*   **Endpoint:** `POST /warehouses/`
*   **Description:** Creates a new warehouse. The creator is automatically assigned as the owner.
*   **Request Body:**
    ```json
    {
      "name": "string",
      "description": "string"
    }
    ```
*   **Success Response (201 Created):**
    ```json
    {
      "status": "success",
      "data": {
        "name": "string",
        "description": "string",
        "warehouse_id": 1,
        "created_by_user_id": 1,
        "creator": {
          "username": "string",
          "email": "user@example.com",
          "user_id": 1
        }
      },
      "message": "Warehouse created successfully"
    }
    ```

### 2. Get User's Warehouses

*   **Endpoint:** `GET /warehouses/`
*   **Description:** Retrieves a list of all warehouses the current user has access to.
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": [
        {
          "name": "string",
          "description": "string",
          "warehouse_id": 1,
          "created_by_user_id": 1,
          "creator": {
            "username": "string",
            "email": "user@example.com",
            "user_id": 1
          }
        }
      ],
      "message": "Warehouses retrieved successfully"
    }
    ```

### 3. Invite User to Warehouse

*   **Endpoint:** `POST /warehouses/{warehouse_id}/invite`
*   **Description:** Invites another user (by email) to a warehouse. Only the warehouse owner can perform this action.
*   **URL Parameters:**
    *   `warehouse_id`: The ID of the warehouse.
*   **Query Parameters:**
    *   `invited_user_email`: The email of the user to invite.
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": {
        "user_id": 2,
        "warehouse_id": 1,
        "role": "member",
        "id": 2,
        "user": {
          "username": "invited_user",
          "email": "invited@example.com",
          "user_id": 2
        }
      },
      "message": "User invited to warehouse successfully"
    }
    ```
*   **Error Response (403 Forbidden):**
    *   If the current user is not the owner of the warehouse.
*   **Error Response (400 Bad Request):**
    *   If the invited user is not found or is already a member.

---

## Items Module

**Prefix:** `/items`
**Authentication:** Required for all endpoints.

### 1. Create Item

*   **Endpoint:** `POST /items/`
*   **Description:** Creates a new item in a specified warehouse.
*   **Request Body:**
    ```json
    {
      "name": "string",
      "category": "string",
      "location": "string",
      "quantity": 1,
      "warehouse_id": 1
    }
    ```
*   **Success Response (201 Created):**
    ```json
    {
      "status": "success",
      "data": {
        "name": "string",
        "category": "string",
        "location": "string",
        "quantity": 1,
        "item_id": 1,
        "warehouse_id": 1
      },
      "message": "Item created successfully"
    }
    ```
*   **Error Response (403 Forbidden):**
    *   If the user does not have access to the specified warehouse.

### 2. Get Items in Warehouse

*   **Endpoint:** `GET /items/warehouse/{warehouse_id}`
*   **Description:** Retrieves all items within a specific warehouse.
*   **URL Parameters:**
    *   `warehouse_id`: The ID of the warehouse.
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": [
        {
          "name": "string",
          "category": "string",
          "location": "string",
          "quantity": 1,
          "item_id": 1,
          "warehouse_id": 1
        }
      ],
      "message": "Items retrieved successfully"
    }
    ```
*   **Error Response (403 Forbidden):**
    *   If the user does not have access to the specified warehouse.

### 3. Get Item Details

*   **Endpoint:** `GET /items/{item_id}`
*   **Description:** Retrieves the details of a specific item.
*   **URL Parameters:**
    *   `item_id`: The ID of the item.
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": {
        "name": "string",
        "category": "string",
        "location": "string",
        "quantity": 1,
        "item_id": 1,
        "warehouse_id": 1
      },
      "message": "Item details retrieved successfully"
    }
    ```
*   **Error Response (404 Not Found):**
    *   If the item does not exist.
*   **Error Response (403 Forbidden):**
    *   If the user does not have access to the item's warehouse.

### 4. Update Item

*   **Endpoint:** `PUT /items/{item_id}`
*   **Description:** Updates the details of a specific item.
*   **URL Parameters:**
    *   `item_id`: The ID of the item.
*   **Request Body:**
    ```json
    {
      "name": "string",
      "category": "string",
      "location": "string",
      "quantity": 1
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": {
        "name": "string",
        "category": "string",
        "location": "string",
        "quantity": 1,
        "item_id": 1,
        "warehouse_id": 1
      },
      "message": "Item updated successfully"
    }
    ```
*   **Error Response (404 Not Found):**
    *   If the item does not exist.
*   **Error Response (403 Forbidden):**
    *   If the user does not have permission to update items in the warehouse.

### 5. Delete Item

*   **Endpoint:** `DELETE /items/{item_id}`
*   **Description:** Deletes a specific item. Only warehouse owners can perform this action.
*   **URL Parameters:**
    *   `item_id`: The ID of the item.
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": null,
      "message": "Item deleted successfully"
    }
    ```
*   **Error Response (404 Not Found):**
    *   If the item does not exist.
*   **Error Response (403 Forbidden):**
    *   If the user is not an owner of the item's warehouse.

---

## Media Module

**Prefix:** `/media`
**Authentication:** Required for all endpoints.

### 1. Upload Item Media

*   **Endpoint:** `POST /media/upload/{item_id}`
*   **Description:** Uploads an image or video for a specific item.
*   **URL Parameters:**
    *   `item_id`: The ID of the item to associate the media with.
*   **Request Body:** `multipart/form-data`
    *   `file`: The image or video file to upload.
*   **Success Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": {
        "file_url": "/uploads/some-uuid.jpg",
        "file_type": "image",
        "id": 1
      },
      "message": "Media uploaded successfully"
    }
    ```
*   **Error Response (404 Not Found):**
    *   If the item does not exist.
*   **Error Response (403 Forbidden):**
    *   If the user does not have access to the item's warehouse.
*   **Error Response (400 Bad Request):**
    *   If the uploaded file type is not supported (only `image/*` and `video/*` are allowed).
