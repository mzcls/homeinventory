# Flutter App Structure Documentation

This document outlines the structure of the Flutter application for the Home Inventory system.

## Directory Structure

The `lib` directory is organized as follows:

```
lib/
 ├── main.dart          # App entry point, provider setup, and routing
 ├── config.dart        # Global configuration, e.g., API base URL
 │
 ├── pages/             # UI screens for different parts of the app
 │    ├── login_page.dart
 │    ├── register_page.dart
 │    ├── warehouse_list_page.dart
 │    ├── item_list_page.dart
 │    ├── add_warehouse_page.dart
 │    ├── add_item_page.dart
 │    ├── edit_item_page.dart
 │    └── item_detail_page.dart
 │
 ├── widgets/           # Reusable UI components
 │    └── image_upload.dart
 │
 ├── services/          # Services for communicating with the backend API
 │    ├── auth_service.dart
 │    ├── warehouse_service.dart
 │    ├── item_service.dart
 │    └── media_service.dart
 │
 ├── models/            # Data models for the app
 │    ├── user.dart
 │    ├── warehouse.dart
 │    ├── item.dart
 │    └── item_media.dart
 │
 └── providers/         # State management using the Provider package
      ├── auth_provider.dart
      ├── warehouse_provider.dart
      ├── item_provider.dart
      └── media_provider.dart
```

## Key Components

*   **`main.dart`**: Initializes the app, sets up `MultiProvider` for state management, and handles the initial routing logic based on authentication state.
*   **`pages/`**: Each file in this directory represents a distinct screen in the app.
*   **`widgets/`**: Contains smaller, reusable widgets that can be used across multiple pages.
*   **`models/`**: Defines the data structures (e.g., `User`, `Item`) that mirror the data received from the backend. These models include `fromJson` factories for easy deserialization of JSON data.
*   **`services/`**: These classes are responsible for making HTTP requests to the backend API using the `dio` package. Each service corresponds to a specific area of the API (e.g., `AuthService` for authentication).
*   **`providers/`**: These classes use the `ChangeNotifier` mixin and the `provider` package to manage the application's state. They fetch data from the services, hold the state, and notify listeners (the UI) of any changes.

## State Management

The app uses the `provider` package for state management.

*   **`AuthProvider`**: Manages the user's authentication state, including the JWT token. It also handles auto-login by reading the token from `SharedPreferences`.
*   **`WarehouseProvider`**: Manages the state of warehouses, including fetching the list of warehouses and creating new ones.
*   **`ItemProvider`**: Manages the state of items within a warehouse. It handles fetching, creating, updating, and deleting items.
*   **`MediaProvider`**: Manages the state of media uploads.

## Dependencies

*   **`dio`**: For making HTTP requests to the backend API.
*   **`provider`**: For state management.
*   **`image_picker`**: For selecting images/videos from the device's camera or gallery.
*   **`shared_preferences`**: For persisting the authentication token locally on the device.
