# 家庭物品管理系统
## 简介

- 服务端
  

- 客户端


## 部署

- 服务端
  
在`backend`新建.env文件
```
UPLOAD_DIR=./uploads   ## 可自定义文件上传目录
SECRET_KEY=生成强密钥
```

数据库配置
```
DATABASE_URL 环境变量
值 mysql+mysqlconnector://user:password@host/db

```
启动服务端
```
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

- 客户端
  
  在config.dart中配置服务端地址，然后重新编译
  ```
    static const String apiBaseUrl = 'http://10.0.1.6:8000';
  ```