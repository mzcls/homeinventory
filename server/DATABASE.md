# 数据库设计文档

本文档概述了家庭物品管理系统使用的 MySQL 数据库的模式。

## 表

### 1. `user` (用户表)

存储用户账户信息。

| 列名            | 类型           | 约束条件           | 描述                                     |
|---------------|----------------|--------------------|------------------------------------------|
| `user_id`     | INT            | AUTO_INCREMENT, PK | 用户的唯一标识符。                       |
| `username`    | VARCHAR(50)    | NOT NULL, UNIQUE   | 用户选择的用户名。                       |
| `email`       | VARCHAR(100)   | UNIQUE             | 用户的电子邮件地址 (可选)。              |
| `password_hash` | VARCHAR(255)   | NOT NULL           | 用户的哈希密码。                         |
| `is_admin`    | BOOLEAN        | DEFAULT FALSE      | 是否为管理员用户。                       |
| `created_at`  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP | 用户创建时间。                           |
| `updated_at`  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 用户信息最后更新时间。                   |

### 2. `warehouse` (仓库表)

存储每个仓库的信息。

| 列名                | 类型           | 约束条件           | 描述                                     |
|-------------------|----------------|--------------------|------------------------------------------|
| `warehouse_id`    | INT            | AUTO_INCREMENT, PK | 仓库的唯一标识符。                       |
| `name`            | VARCHAR(100)   | NOT NULL           | 仓库名称。                               |
| `description`     | TEXT           | NULL               | 仓库的描述 (可选)。                      |
| `created_by_user_id` | INT            | NOT NULL, FK       | 创建该仓库的用户 ID。                    |
| `created_at`      | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP | 仓库创建时间。                           |
| `updated_at`      | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 仓库信息最后更新时间。                   |

### 3. `user_warehouse` (用户-仓库映射表)

链接用户与仓库，并定义其角色。

| 列名            | 类型                  | 约束条件           | 描述                                     |
|---------------|-----------------------|--------------------|------------------------------------------|
| `id`          | INT                   | AUTO_INCREMENT, PK | 映射记录的唯一标识符。                   |
| `user_id`     | INT                   | NOT NULL, FK       | 用户的 ID。                              |
| `warehouse_id` | INT                   | NOT NULL, FK       | 仓库的 ID。                              |
| `role`        | ENUM('owner', 'member') | NOT NULL           | 用户在仓库中的角色。                     |
| `created_at`  | TIMESTAMP             | DEFAULT CURRENT_TIMESTAMP | 映射创建时间。                           |
| `updated_at`  | TIMESTAMP             | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 映射信息最后更新时间。                   |

### 4. `category` (分类表)

存储物品分类信息。

| 列名            | 类型           | 约束条件           | 描述                                     |
|---------------|----------------|--------------------|------------------------------------------|
| `category_id` | INT            | AUTO_INCREMENT, PK | 分类的唯一标识符。                       |
| `name`        | VARCHAR(100)   | NOT NULL           | 分类名称。                               |
| `warehouse_id` | INT            | NOT NULL, FK       | 所属仓库的 ID。                          |
| `created_at`  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP | 分类创建时间。                           |
| `updated_at`  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 分类信息最后更新时间。                   |

### 5. `item` (物品表)

存储每个物品的信息。

| 列名            | 类型           | 约束条件           | 描述                                     |
|---------------|----------------|--------------------|------------------------------------------|
| `item_id`     | INT            | AUTO_INCREMENT, PK | 物品的唯一标识符。                       |
| `name`        | VARCHAR(255)   | NOT NULL           | 物品名称。                               |
| `category_id` | INT            | NOT NULL, FK       | 物品所属分类的 ID。                      |
| `location`    | VARCHAR(255)   | NULL               | 物品在仓库中的具体位置。                 |
| `quantity`    | INT            | NOT NULL, DEFAULT 1 | 物品数量。                               |
| `warehouse_id` | INT            | NOT NULL, FK       | 物品所属仓库的 ID。                      |
| `deleted_at`  | TIMESTAMP      | NULL               | 物品软删除时间戳。                       |
| `created_at`  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP | 物品创建时间。                           |
| `updated_at`  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 物品信息最后更新时间。                   |

### 6. `item_media` (物品文件表)

存储与物品关联的媒体文件（图片/视频）的引用。

| 列名            | 类型                   | 约束条件           | 描述                                     |
|---------------|------------------------|--------------------|------------------------------------------|
| `id`          | INT                    | AUTO_INCREMENT, PK | 媒体记录的唯一标识符。                   |
| `item_id`     | INT                    | NOT NULL, FK       | 媒体文件关联的物品 ID。                  |
| `file_url`    | VARCHAR(255)           | NOT NULL           | 媒体文件的 URL。                         |
| `file_type`   | ENUM('image', 'video') | NOT NULL           | 媒体文件的类型。                         |
| `created_at`  | TIMESTAMP              | DEFAULT CURRENT_TIMESTAMP | 媒体文件创建时间。                       |

## 关系

*   一个 `User` 可以创建多个 `Warehouse`。
*   一个 `User` 可以是多个 `Warehouse` 的成员，一个 `Warehouse` 可以有多个 `User`（通过 `user_warehouse` 表实现多对多关系）。
*   一个 `Warehouse` 可以包含多个 `Item`。
*   一个 `Item` 可以有多个 `ItemMedia` 文件。
*   一个 `Warehouse` 可以有多个 `Category`。
*   一个 `Category` 可以包含多个 `Item`。