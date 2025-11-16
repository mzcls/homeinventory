# 项目名称：家庭物品管理系统（多用户、多仓库）

## 项目总体说明

本项目旨在开发一个家庭物品管理系统，包括 Flutter 移动应用前端（安卓优先）、Python 3 + FastAPI 后端以及 MySQL 数据库。系统支持多用户、多仓库共享机制，用户可以记录家中物品的详细信息，并与他人共享管理。

### 核心功能

*   **物品信息记录：** 物品名称、分类、位置（房间、柜子等）、数量、图片/视频。
*   **多用户、多仓库共享：**
    *   用户可以创建自己的仓库。
    *   仓库所有者可以邀请其他用户加入仓库，共同添加/编辑/查看物品。
    *   支持多个用户共享多个仓库。
*   **权限管理：** 细粒度的用户-仓库角色（所有者/成员）。
*   **图片/视频存储：** 支持后端本地存储。

### 技术栈

*   **前端：** Flutter (Dart)
*   **后端：** Python 3 + FastAPI
*   **数据库：** MySQL

## 权限模型

系统实现以下权限模型：

1.  **用户 (User)**
    *   字段：`user_id`, `username`, `email` (可选), `password_hash`, `is_admin` (首个注册用户默认为管理员)。
2.  **仓库 (Warehouse)**
    *   字段：`warehouse_id`, `name`, `description`, `created_by_user_id`。
3.  **用户-仓库映射 (UserWarehouse)**
    *   用于多用户共享仓库。
    *   字段：`id`, `user_id`, `warehouse_id`, `role` (`owner`/`member`)。
4.  **物品 (Item)**
    *   字段：`item_id`, `name`, `category_id`, `location`, `quantity`, `warehouse_id`, `deleted_at` (软删除时间戳)。
5.  **物品文件 (ItemMedia)**
    *   字段：`id`, `item_id`, `file_url`, `file_type` (`image`/`video`)。
6.  **分类 (Category)**
    *   字段：`category_id`, `name`, `warehouse_id`。

**权限检查：** 确保所有操作都经过仓库归属和用户权限检查。

## 数据库设计

以下是完整的 MySQL 建表语句（已包含索引、主键、外键）：

```sql
-- 用户表
CREATE TABLE `user` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `email` VARCHAR(100) UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `is_admin` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 仓库表
CREATE TABLE `warehouse` (
    `warehouse_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `created_by_user_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`created_by_user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE
);

-- 用户-仓库映射表
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

-- 分类表
CREATE TABLE `category` (
    `category_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `warehouse_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (`name`, `warehouse_id`), -- 同一仓库下分类名称唯一
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`warehouse_id`) ON DELETE CASCADE
);

-- 物品表
CREATE TABLE `item` (
    `item_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `category_id` INT NOT NULL, -- 物品分类现在是必填项
    `location` VARCHAR(255),
    `quantity` INT NOT NULL DEFAULT 1,
    `warehouse_id` INT NOT NULL,
    `deleted_at` TIMESTAMP NULL, -- 软删除字段
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`warehouse_id`) ON DELETE CASCADE,
    FOREIGN KEY (`category_id`) REFERENCES `category`(`category_id`) ON DELETE RESTRICT -- 分类被使用时不能删除
);

-- 物品文件表
CREATE TABLE `item_media` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `item_id` INT NOT NULL,
    `file_url` VARCHAR(255) NOT NULL,
    `file_type` ENUM('image', 'video') NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE CASCADE
);
```

## 后端 FastAPI

后端项目结构如下：

```
backend/
 ├── app/
 │    ├── main.py
 │    ├── models/         # SQLAlchemy 模型定义
 │    ├── routes/         # API 路由定义
 │    ├── schemas/        # Pydantic 数据模型
 │    ├── services/       # 业务逻辑服务
 │    ├── utils/          # 工具函数 (如 JWT, 密码哈希)
 │    └── database.py     # 数据库连接与会话管理
 └── requirements.txt    # Python 依赖
```

### 统一返回格式

所有接口返回数据统一采用以下格式：

```json
{
  "status": "success" | "error",
  "data": {...},
  "message": "操作结果描述"
}
```

### 接口列表 (API Documentation)

#### 🔑 1. 用户认证模块 (Auth)

*   **注册用户**
    *   **URL:** `/auth/register`
    *   **方法:** `POST`
    *   **描述:** 注册新用户。首个注册用户将自动成为管理员。
    *   **请求体:** `UserCreate` (username, password, email(可选))
    *   **响应:** `ResponseModel[UserResponse]`
*   **用户登录**
    *   **URL:** `/auth/token`
    *   **方法:** `POST`
    *   **描述:** 用户登录并获取 JWT 访问令牌。
    *   **请求体:** `OAuth2PasswordRequestForm` (username, password)
    *   **响应:** `ResponseModel[Token]`
*   **获取当前用户信息**
    *   **URL:** `/auth/users/me`
    *   **方法:** `GET`
    *   **描述:** 获取当前登录用户的详细信息。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **响应:** `ResponseModel[UserResponse]`
*   **修改当前用户密码**
    *   **URL:** `/auth/users/me/password`
    *   **方法:** `PUT`
    *   **描述:** 当前登录用户修改自己的密码，无需提供旧密码。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **请求体:** `{"new_password": "新密码"}`
    *   **响应:** `ResponseModel` (message: "Password updated successfully")

#### 🏭 2. 仓库模块 (Warehouse)

*   **创建仓库**
    *   **URL:** `/warehouses/`
    *   **方法:** `POST`
    *   **描述:** 创建一个新的仓库，创建者自动成为所有者。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **请求体:** `WarehouseCreate` (name, description(可选))
    *   **响应:** `ResponseModel[WarehouseResponse]`
*   **获取用户可访问仓库列表**
    *   **URL:** `/warehouses/`
    *   **方法:** `GET`
    *   **描述:** 获取当前用户有权限访问的所有仓库列表。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **响应:** `ResponseModel[List[WarehouseResponse]]`
*   **邀请其他用户加入仓库**
    *   **URL:** `/warehouses/{warehouse_id}/invite`
    *   **方法:** `POST`
    *   **描述:** 仓库所有者邀请其他用户加入仓库。被邀请用户通过用户名查找，并以成员身份加入。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `warehouse_id` (int)
    *   **查询参数:** `invited_username` (str)
    *   **响应:** `ResponseModel[UserWarehouseResponse]`
*   **删除仓库**
    *   **URL:** `/warehouses/{warehouse_id}`
    *   **方法:** `DELETE`
    *   **描述:** 删除指定仓库。只有仓库所有者可以删除。如果仓库包含物品、分类或用户分配，则无法删除。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `warehouse_id` (int)
    *   **响应:** `ResponseModel` (message: "Warehouse deleted successfully")

#### 📦 3. 物品管理模块 (Item)

*   **创建物品**
    *   **URL:** `/items/`
    *   **方法:** `POST`
    *   **描述:** 在指定仓库下创建新物品。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **请求体:** `ItemCreate` (name, category_id, location, quantity, warehouse_id)
    *   **响应:** `ResponseModel[ItemResponse]`
*   **编辑物品**
    *   **URL:** `/items/{item_id}`
    *   **方法:** `PUT`
    *   **描述:** 编辑指定物品的信息。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `item_id` (int)
    *   **请求体:** `ItemUpdate` (name, category_id, location, quantity)
    *   **响应:** `ResponseModel[ItemResponse]`
*   **删除物品 (软删除)**
    *   **URL:** `/items/{item_id}`
    *   **方法:** `DELETE`
    *   **描述:** 软删除指定物品（设置 `deleted_at` 字段）。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `item_id` (int)
    *   **响应:** `ResponseModel` (message: "Item soft-deleted successfully")
*   **按仓库获取物品列表**
    *   **URL:** `/warehouses/{warehouse_id}/items`
    *   **方法:** `GET`
    *   **描述:** 获取指定仓库下的所有**未删除**物品列表。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `warehouse_id` (int)
    *   **响应:** `ResponseModel[List[ItemResponse]]`
*   **获取已删除物品列表**
    *   **URL:** `/warehouses/{warehouse_id}/items/deleted`
    *   **方法:** `GET`
    *   **描述:** 获取指定仓库下的所有**已删除**物品列表。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `warehouse_id` (int)
    *   **响应:** `ResponseModel[List[ItemResponse]]`
*   **恢复已删除物品**
    *   **URL:** `/items/{item_id}/restore`
    *   **方法:** `PUT`
    *   **描述:** 恢复一个已软删除的物品（清除 `deleted_at` 字段）。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `item_id` (int)
    *   **响应:** `ResponseModel[ItemResponse]`
*   **查看物品详情**
    *   **URL:** `/items/{item_id}`
    *   **方法:** `GET`
    *   **描述:** 获取指定物品的详细信息，包括关联的媒体文件。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `item_id` (int)
    *   **响应:** `ResponseModel[ItemResponse]`
*   **全局物品搜索**
    *   **URL:** `/items/search`
    *   **方法:** `GET`
    *   **描述:** 在用户有权限访问的所有仓库中，根据关键词全局搜索物品。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **查询参数:** `query` (str)
    *   **响应:** `ResponseModel[List[ItemResponse]]`

#### 🖼️ 4. 上传模块 (Media)

*   **上传图片/视频**
    *   **URL:** `/media/upload/{item_id}`
    *   **方法:** `POST`
    *   **描述:** 为指定物品上传图片或视频。支持图片压缩。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `item_id` (int)
    *   **请求体:** `multipart/form-data` (file: File, file_type: "image" | "video")
    *   **响应:** `ResponseModel[ItemMediaResponse]`
*   **删除物品媒体**
    *   **URL:** `/media/{media_id}`
    *   **方法:** `DELETE`
    *   **描述:** 删除指定物品的媒体文件。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `media_id` (int)
    *   **响应:** `ResponseModel` (message: "Media deleted successfully")

#### 🏷️ 5. 分类管理模块 (Category)

*   **创建分类**
    *   **URL:** `/categories/`
    *   **方法:** `POST`
    *   **描述:** 为指定仓库创建新分类。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **请求体:** `CategoryCreate` (name, warehouse_id)
    *   **响应:** `ResponseModel[CategoryResponse]`
*   **获取仓库分类列表**
    *   **URL:** `/warehouses/{warehouse_id}/categories`
    *   **方法:** `GET`
    *   **描述:** 获取指定仓库下的所有分类。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `warehouse_id` (int)
    *   **响应:** `ResponseModel[List[CategoryResponse]]`
*   **删除分类**
    *   **URL:** `/categories/{category_id}`
    *   **方法:** `DELETE`
    *   **描述:** 删除指定分类。只有当分类未被任何**活动物品**使用时才能删除。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `category_id` (int)
    *   **响应:** `ResponseModel` (message: "Category deleted successfully")

#### 👮 6. 管理员模块 (Admin)

*   **获取所有用户**
    *   **URL:** `/admin/users`
    *   **方法:** `GET`
    *   **描述:** 获取系统中所有用户的列表。仅限管理员访问。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **响应:** `ResponseModel[List[UserResponse]]`
*   **获取所有仓库**
    *   **URL:** `/admin/warehouses`
    *   **方法:** `GET`
    *   **描述:** 获取系统中所有仓库的列表。仅限管理员访问。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **响应:** `ResponseModel[List[WarehouseResponse]]`
*   **分配/更新用户仓库权限**
    *   **URL:** `/admin/assign_warehouse`
    *   **方法:** `POST`
    *   **描述:** 为指定用户分配或更新指定仓库的权限（所有者/成员）。仅限管理员访问。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **请求体:** `UserWarehouseCreate` (user_id, warehouse_id, role)
    *   **响应:** `ResponseModel[UserWarehouseResponse]`
*   **移除用户仓库权限**
    *   **URL:** `/admin/remove_warehouse_assignment`
    *   **方法:** `DELETE`
    *   **描述:** 移除指定用户在指定仓库的权限。仅限管理员访问。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **查询参数:** `user_id` (int), `warehouse_id` (int)
    *   **响应:** `ResponseModel` (message: "User removed from warehouse successfully")
*   **重置用户密码**
    *   **URL:** `/admin/users/{user_id}/reset-password`
    *   **方法:** `PUT`
    *   **描述:** 将指定用户的密码重置为默认值 "123456"。仅限管理员访问。
    *   **请求头:** `Authorization: Bearer <token>`
    *   **路径参数:** `user_id` (int)
    *   **响应:** `ResponseModel` (message: "User password reset to '123456' successfully")

## Flutter App 前端

### 项目结构

```
lib/
 ├── main.dart           # 应用入口
 ├── pages/              # 页面组件
 │    ├── login_page.dart
 │    ├── register_page.dart
 │    ├── warehouse_list_page.dart
 │    ├── main_scaffold_page.dart (包含物品列表、历史物品、设置)
 │    ├── item_list_page.dart
 │    ├── item_detail_page.dart
 │    ├── add_item_page.dart
 │    ├── edit_item_page.dart
 │    ├── deleted_items_page.dart
 │    ├── settings_page.dart
 │    ├── admin_panel_page.dart
 │    ├── category_management_page.dart
 │    ├── item_search_page.dart
 │    └── change_password_page.dart # 新增：修改密码页面
 ├── widgets/            # 可复用小组件 (如图片上传组件, 认证包装器)
 │    ├── auth_wrapper.dart
 │    └── image_upload.dart
 ├── services/           # 后端 API 调用服务
 │    ├── auth_service.dart
 │    ├── warehouse_service.dart
 │    ├── item_service.dart
 │    ├── media_service.dart
 │    ├── category_service.dart
 │    └── admin_service.dart
 ├── models/             # 数据模型 (Pydantic 对应)
 │    ├── user.dart
 │    ├── warehouse.dart
 │    ├── user_warehouse.dart
 │    ├── item.dart
 │    ├── item_media.dart
 │    └── category.dart
 ├── providers/          # 状态管理 (使用 Provider)
 │    ├── auth_provider.dart
 │    ├── warehouse_provider.dart
 │    ├── item_provider.dart
 │    ├── media_provider.dart
 │    ├── category_provider.dart
 │    ├── admin_provider.dart
 │    └── item_search_provider.dart
 └── config.dart         # API 地址配置
```

### 页面列表

*   **登录 / 注册页：** 用户登录和注册入口。支持记住账号密码。
*   **仓库列表页：** 显示用户可访问的所有仓库。支持长按删除仓库。
*   **物品列表页 (按仓库)：** 显示选定仓库下的所有活动物品。
*   **添加/编辑物品页：** 添加新物品或编辑现有物品。分类和位置为必填项。
*   **物品详情页：** 显示物品详细信息，包括图片/视频。支持图片/视频滑动查看、删除。
*   **上传图片/视频组件：** 用于物品的图片和视频上传，支持图片压缩。
*   **全局物品搜索页：** 搜索用户所有仓库中的物品。
*   **分类管理页：** 管理当前仓库下的分类，支持添加、列表、删除（检查物品依赖）。
*   **设置页：** 包含“分类管理”、“修改密码”和“退出登录”选项。管理员用户额外显示“后台管理”入口。
*   **修改密码页：** 用户在此页面修改自己的密码。
*   **后台管理页 (仅管理员可见)：**
    *   显示所有用户和所有仓库。
    *   管理员可以为用户分配/更新/移除仓库权限。
    *   管理员可以重置任何用户的密码为“123456”。

### 技术要求

*   **网络请求：** 使用 `Dio` 库。
*   **状态管理：** 使用 `Provider` 库。
*   **图片/视频选择与处理：** 使用 `image_picker` 库，图片上传前进行压缩 (`flutter_image_compress`)。
*   **列表交互：** 支持搜索、筛选。
*   **UI 设计：** 简洁清晰，所有用户提示和界面文本均为中文。
*   **API 配置：** 所有 API 地址统一配置在 `config.dart` 文件中。

## 最终交付文档

本部分将总结项目架构、后端 API、数据库设计和 Flutter 前端结构，作为开发团队的参考文档。

### ✔ 架构图

（此处应包含系统架构图，例如：用户通过 Flutter App 访问 FastAPI 后端，后端与 MySQL 数据库交互，媒体文件存储在本地文件系统。）

### ✔ 后端 API 文档

（详见上文“后端 FastAPI -> 接口列表”部分）

### ✔ 数据库设计文档

（详见上文“数据库设计”部分）

### ✔ Flutter 前端结构文档

（详见上文“Flutter App 前端 -> 项目结构”和“页面列表”部分）

### ✔ 全项目提示词总结

（此部分将包含用于生成此项目的关键提示词，以便未来迭代或复现。）
