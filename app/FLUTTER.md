# Flutter 应用结构文档

本文档概述了家庭物品管理系统 Flutter 应用程序的结构。

## 目录结构

`lib` 目录的组织方式如下：

```
lib/
 ├── main.dart           # 应用入口点、Provider 设置和路由
 ├── config.dart         # 全局配置，例如 API 基础 URL
 │
 ├── pages/              # 应用不同部分的 UI 屏幕
 │    ├── login_page.dart
 │    ├── register_page.dart
 │    ├── warehouse_list_page.dart
 │    ├── main_scaffold_page.dart (包含物品列表、历史物品、设置)
 │    ├── item_list_page.dart
 │    ├── add_warehouse_page.dart
 │    ├── add_item_page.dart
 │    ├── edit_item_page.dart
 │    ├── item_detail_page.dart
 │    ├── deleted_items_page.dart
 │    ├── settings_page.dart
 │    ├── admin_panel_page.dart
 │    ├── category_management_page.dart
 │    ├── item_search_page.dart
 │    └── change_password_page.dart # 新增：修改密码页面
 │
 ├── widgets/            # 可复用的 UI 组件
 │    ├── auth_wrapper.dart
 │    └── image_upload.dart
 │
 ├── services/           # 与后端 API 通信的服务
 │    ├── auth_service.dart
 │    ├── warehouse_service.dart
 │    ├── item_service.dart
 │    ├── media_service.dart
 │    ├── category_service.dart
 │    └── admin_service.dart
 │
 ├── models/             # 应用的数据模型
 │    ├── user.dart
 │    ├── warehouse.dart
 │    ├── user_warehouse.dart
 │    ├── item.dart
 │    ├── item_media.dart
 │    └── category.dart
 │
 └── providers/          # 使用 Provider 包进行状态管理
      ├── auth_provider.dart
      ├── warehouse_provider.dart
      ├── item_provider.dart
      ├── media_provider.dart
      ├── category_provider.dart
      ├── admin_provider.dart
      └── item_search_provider.dart
```

## 关键组件

*   **`main.dart`**: 初始化应用程序，设置 `MultiProvider` 进行状态管理，并根据认证状态处理初始路由逻辑。
*   **`pages/`**: 此目录中的每个文件代表应用程序中的一个独立屏幕。
*   **`widgets/`**: 包含可在多个页面中使用的较小的可复用小部件。
*   **`models/`**: 定义数据结构（例如 `User`、`Item`），这些结构与从后端接收到的数据相对应。这些模型包含 `fromJson` 工厂，以便轻松反序列化 JSON 数据。
*   **`services/`**: 这些类负责使用 `dio` 包向后端 API 发送 HTTP 请求。每个服务对应于 API 的特定领域（例如，`AuthService` 用于认证）。
*   **`providers/`**: 这些类使用 `ChangeNotifier` 混入和 `provider` 包来管理应用程序的状态。它们从服务中获取数据，保存状态，并通知监听器（UI）任何更改。

## 状态管理

应用程序使用 `provider` 包进行状态管理。

*   **`AuthProvider`**: 管理用户的认证状态，包括 JWT 令牌。它还通过从 `SharedPreferences` 读取令牌来处理自动登录。
*   **`WarehouseProvider`**: 管理仓库的状态，包括获取仓库列表和创建新仓库。
*   **`ItemProvider`**: 管理仓库中物品的状态。它处理物品的获取、创建、更新和删除。
*   **`MediaProvider`**: 管理媒体上传的状态。
*   **`CategoryProvider`**: 管理分类的状态。
*   **`AdminProvider`**: 管理管理员相关操作的状态，如获取所有用户、仓库，以及分配权限。
*   **`ItemSearchProvider`**: 管理物品搜索的状态。

## 依赖项

*   **`dio`**: 用于向后端 API 发送 HTTP 请求。
*   **`provider`**: 用于状态管理。
*   **`image_picker`**: 用于从设备的相机或图库中选择图片/视频。
*   **`shared_preferences`**: 用于在设备本地持久化认证令牌。
*   **`flutter_image_compress`**: 用于图片上传前的压缩。
*   **`cached_network_image`**: 用于高效加载网络图片。