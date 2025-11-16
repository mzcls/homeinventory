# 家庭物品管理系统 API 文档

## 基础 URL

`http://127.0.0.1:8000` (请根据实际部署情况修改)

## 统一返回格式

所有 API 响应遵循统一格式：

```json
{
  "status": "success" | "error",
  "data": {}, // 实际的响应数据
  "message": "" // 描述性消息
}
```

## 认证

认证使用 JWT (JSON Web Tokens) 处理。要访问受保护的端点，您必须在 `Authorization` 请求头中包含 `Bearer <您的令牌>`。

---

## 🔑 1. 用户认证模块 (Auth)

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

---

## 🏭 2. 仓库模块 (Warehouse)

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

---

## 📦 3. 物品管理模块 (Item)

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

---

## 🖼️ 4. 上传模块 (Media)

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

---

## 🏷️ 5. 分类管理模块 (Category)

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

---

## 👮 6. 管理员模块 (Admin)

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