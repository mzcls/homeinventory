# Architecture Diagram

This diagram illustrates the high-level architecture of the Home Inventory system.

```
+-----------------+      +-----------------+      +-----------------+
|                 |      |                 |      |                 |
|  Flutter App    |----->|   FastAPI Backend |----->|   MySQL DB      |
| (Android)       |      |   (REST API)    |      |                 |
|                 |      |                 |      |                 |
+-----------------+      +-----------------+      +-----------------+
      |                            |                      ^
      |                            |                      |
      |                            v                      |
      |                      +-----------------+          |
      |                      |                 |          |
      +--------------------->|  Object Storage |<---------+
                           | (S3/Aliyun OSS) |
                           | (Optional)      |
                           +-----------------+
```

## Components

*   **Flutter App (Android):** The user-facing mobile application for managing inventory. It communicates with the backend via REST API calls.
*   **FastAPI Backend:** The server-side application that provides the REST API. It handles business logic, authentication, and database interactions.
*   **MySQL Database:** The primary data store for users, warehouses, items, and their relationships.
*   **Object Storage (Optional):** An optional component for storing media files (images/videos). This can be a cloud service like AWS S3 or Aliyun OSS, or local file storage.

## Data Flow

1.  The Flutter app sends HTTP requests to the FastAPI backend.
2.  The FastAPI backend processes the requests, performs business logic, and interacts with the MySQL database.
3.  For media uploads, the backend can store files in either the local filesystem or an object storage service.
4.  The backend returns JSON responses to the Flutter app.
