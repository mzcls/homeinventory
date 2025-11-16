-- Create Database
CREATE DATABASE IF NOT EXISTS `homeinventory`;
USE `homeinventory`;

-- Table: User
CREATE TABLE `user` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(255) NOT NULL UNIQUE,
    `email` VARCHAR(255) NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_admin` BOOLEAN NOT NULL DEFAULT FALSE
);

-- Table: Warehouse
CREATE TABLE `warehouse` (
    `warehouse_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `created_by_user_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE
);

-- Table: UserWarehouse (for many-to-many relationship and roles)
CREATE TABLE `user_warehouse` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `warehouse_id` INT NOT NULL,
    `role` ENUM('owner', 'member') NOT NULL DEFAULT 'member',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (`user_id`, `warehouse_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`warehouse_id`) ON DELETE CASCADE
);

-- Table: Category
CREATE TABLE `category` (
    `category_id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `warehouse_id` INTEGER NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`category_id`),
    INDEX `ix_category_category_id` (`category_id`),
    INDEX `ix_category_name` (`name`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse` (`warehouse_id`) ON DELETE CASCADE
);

-- Table: Item
CREATE TABLE `item` (
    `item_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `location` VARCHAR(255),
    `quantity` INT NOT NULL DEFAULT 1,
    `warehouse_id` INT NOT NULL,
    `category_id` INTEGER NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL DEFAULT NULL,
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`warehouse_id`) ON DELETE CASCADE,
    FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE SET NULL
);

-- Table: ItemMedia
CREATE TABLE `item_media` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `item_id` INT NOT NULL,
    `file_url` VARCHAR(2048) NOT NULL,
    `thumbnail_url` VARCHAR(2048),
    `file_type` ENUM('image', 'video') NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE CASCADE
);