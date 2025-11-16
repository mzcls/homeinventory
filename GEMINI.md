项目名称：家庭物品管理系统（多用户、多仓库）

我需要你为我生成一个完整可运行的项目，包括：

Flutter App 前端（安卓优先）

Python 3 + FastAPI 后端（REST API）

MySQL 数据库结构与建表 SQL

请严格按照以下需求生成内容。

🔥 一、项目总体说明

我要开发一个 Android App（Flutter 实现），用于记录家中的物品信息，包括：

物品名称

物品分类

物品所在位置（如房间、柜子等）

数量

图片或视频

所属仓库

并且要求 App 支持多用户、多仓库共享机制：

用户 A 创建“厨房仓库”

用户 B 可以加入该仓库，并添加/编辑/查看物品

多个用户可以共享多个仓库

整个系统要求：

Flutter 前端

FastAPI 后端

MySQL 数据库

图片/视频可存储在后端本地或 OSS（给出两种方案）

🔐 二、权限模型

必须实现以下模型：

1. 用户（User）

字段包括 user_id, username, email, password_hash

2. 仓库（Warehouse）

字段包括 warehouse_id, name, description, created_by_user_id

3. 用户-仓库映射（UserWarehouse）

用于多用户共享仓库
字段：id, user_id, warehouse_id, role (owner/member)

4. 物品（Item）

字段包括 item_id, name, category, location, quantity, warehouse_id

5. 物品文件（ItemMedia）

字段包括 id, item_id, file_url, file_type(image/video)

确保仓库归属 + 用户权限检查。

📘 三、数据库：请生成完整 MySQL 建表语句

包括：

user

warehouse

user_warehouse

item

item_media

所有字段类型、主键、外键、索引

务必提供可直接运行的 SQL。

🐍 四、后端 FastAPI 要求

请生成完整可运行项目：

后端结构
backend/
 ├── app/
 │    ├── main.py
 │    ├── models/
 │    ├── routes/
 │    ├── schemas/
 │    ├── services/
 │    ├── utils/
 │    └── database.py
 └── requirements.txt

必须包含以下接口：
🔑 1. 用户模块（Auth）

注册

登录（JWT）

获取用户信息

🏭 2. 仓库模块（Warehouse）

创建仓库

获取用户可访问仓库列表

邀请其他用户加入仓库

接受/拒绝邀请（可选）

📦 3. 物品管理模块（Item）

创建物品

编辑物品

删除物品

按仓库获取物品列表

查看物品详情

🖼️ 4. 上传模块（Media）

上传图片/视频

返回 file_url

关联 item

提供两种存储方式：

保存到本地

保存到对象存储（如阿里云、S3）

接口必须使用 Pydantic Schema

要求返回格式统一：

{
  "status": "success",
  "data": {...},
  "message": ""
}

📱 五、Flutter App 要求

请生成 Flutter 前端代码（可分模块给出）：

项目结构
lib/
 ├── main.dart
 ├── pages/
 ├── widgets/
 ├── services/
 ├── models/
 └── providers/

必须包含以下页面：

登录 / 注册

仓库列表页

物品列表页（按仓库）

添加/编辑物品页

物品详情页

上传图片/视频组件

技术要求：

使用 Dio 请求后端

使用 Provider 状态管理

图片视频使用 image_picker

列表可搜索筛选

UI 要简洁清晰

所有 API 地址统一配置在 config.dart。

📌 六、为我生成一个最终可直接交给开发团队使用的文档

内容包括：

✔ 架构图
✔ 后端 API 文档
✔ 数据库设计文档
✔ Flutter 前端结构文档
✔ 全项目提示词总结（可再次用于生成代码）
👇 请按照以上全部要求生成：

完整 MySQL 建表语句

完整 FastAPI 后端代码（可运行）

完整 Flutter App 架构与核心代码

可直接交付给开发团队的文档

所有说明均使用中文

✨（提示词结束）

你可以开始生成结果了。