# Database Design Documentation

This document outlines the schema for the MySQL database used in the Home Inventory system.

## Tables

### 1. `user`

Stores user account information.

| Column          | Type           | Constraints      | Description                               |
|-----------------|----------------|------------------|-------------------------------------------|
| `user_id`       | INT            | AUTO_INCREMENT, PK | Unique identifier for the user.           |
| `username`      | VARCHAR(255)   | NOT NULL, UNIQUE | User's chosen username.                   |
| `email`         | VARCHAR(255)   | NOT NULL, UNIQUE | User's email address.                     |
| `password_hash` | VARCHAR(255)   | NOT NULL         | Hashed password for the user.             |
| `created_at`    | TIMESTAMP      | DEFAULT NOW()    | Timestamp of when the user was created.   |
| `updated_at`    | TIMESTAMP      | DEFAULT NOW()    | Timestamp of the last update to the user. |

### 2. `warehouse`

Stores information about each warehouse.

| Column               | Type         | Constraints      | Description                                  |
|----------------------|--------------|------------------|----------------------------------------------|
| `warehouse_id`       | INT          | AUTO_INCREMENT, PK | Unique identifier for the warehouse.         |
| `name`               | VARCHAR(255) | NOT NULL         | Name of the warehouse.                       |
| `description`        | TEXT         | NULL             | Optional description of the warehouse.       |
| `created_by_user_id` | INT          | NOT NULL, FK     | The `user_id` of the user who created it.    |
| `created_at`         | TIMESTAMP    | DEFAULT NOW()    | Timestamp of when the warehouse was created. |
| `updated_at`         | TIMESTAMP    | DEFAULT NOW()    | Timestamp of the last update.                |

### 3. `user_warehouse`

A mapping table that links users to warehouses, defining their roles.

| Column         | Type                  | Constraints      | Description                                      |
|----------------|-----------------------|------------------|--------------------------------------------------|
| `id`           | INT                   | AUTO_INCREMENT, PK | Unique identifier for the mapping.               |
| `user_id`      | INT                   | NOT NULL, FK     | The `user_id` of the user.                       |
| `warehouse_id` | INT                   | NOT NULL, FK     | The `warehouse_id` of the warehouse.             |
| `role`         | ENUM('owner', 'member') | NOT NULL         | The user's role in the warehouse.                |
| `created_at`   | TIMESTAMP             | DEFAULT NOW()    | Timestamp of when the mapping was created.       |
| `updated_at`   | TIMESTAMP             | DEFAULT NOW()    | Timestamp of the last update.                    |

### 4. `item`

Stores information about each inventory item.

| Column         | Type         | Constraints      | Description                                  |
|----------------|--------------|------------------|----------------------------------------------|
| `item_id`      | INT          | AUTO_INCREMENT, PK | Unique identifier for the item.              |
| `name`         | VARCHAR(255) | NOT NULL         | Name of the item.                            |
| `category`     | VARCHAR(255) | NULL             | Category of the item.                        |
| `location`     | VARCHAR(255) | NULL             | Location of the item within the warehouse.   |
| `quantity`     | INT          | NOT NULL, DEFAULT 1 | Quantity of the item.                        |
| `warehouse_id` | INT          | NOT NULL, FK     | The `warehouse_id` where the item is located. |
| `created_at`   | TIMESTAMP    | DEFAULT NOW()    | Timestamp of when the item was created.      |
| `updated_at`   | TIMESTAMP    | DEFAULT NOW()    | Timestamp of the last update.                |

### 5. `item_media`

Stores references to media files (images/videos) associated with items.

| Column      | Type                   | Constraints      | Description                                  |
|-------------|------------------------|------------------|----------------------------------------------|
| `id`        | INT                    | AUTO_INCREMENT, PK | Unique identifier for the media record.      |
| `item_id`   | INT                    | NOT NULL, FK     | The `item_id` this media is associated with. |
| `file_url`  | VARCHAR(2048)          | NOT NULL         | URL to the media file.                       |
| `file_type` | ENUM('image', 'video') | NOT NULL         | The type of the media file.                  |
| `created_at`| TIMESTAMP              | DEFAULT NOW()    | Timestamp of when the media was created.     |
| `updated_at`| TIMESTAMP              | DEFAULT NOW()    | Timestamp of the last update.                |

## Relationships

*   A `User` can create many `Warehouse`s.
*   A `User` can be a member of many `Warehouse`s, and a `Warehouse` can have many `User`s (many-to-many via `user_warehouse`).
*   A `Warehouse` can contain many `Item`s.
*   An `Item` can have many `ItemMedia` files.
