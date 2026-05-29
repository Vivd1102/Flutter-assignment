# GitHub User Explorer

A Flutter application that uses the GitHub Users API to display, search, and manage favorite GitHub users.

## Features

### Core Features
- 📋 **Users List** - Browse GitHub users with infinite scroll pagination
- 🔍 **Search** - Search users with debounced API calls (500ms delay)
- 👤 **User Details** - View detailed profile information including:
  - Avatar, name, and bio
  - Public repos, followers, following, and gists count
  - Company, location, email, and website
  - Join date
- ❤️ **Favorites** - Save users to favorites with persistence (survives app restart)
- 🔗 **GitHub Link** - Open user profiles directly on GitHub

### Technical Features
- 🏗️ **Clean Architecture** - Proper separation of concerns (Data, Domain, Presentation layers)
- 📱 **Responsive UI** - Works on all screen sizes
- 🌐 **Offline Support** - Cached users available when offline
- 🔄 **Pull-to-Refresh** - Refresh users list easily
- ⚡ **Shimmer Loading** - Beautiful loading skeleton UI
- ❌ **Error Handling** - Graceful error states with retry functionality
- 🌓 **Dark Mode** - Supports system light/dark theme
- 🎯 **Material 3** - Modern Material Design 3 UI

## Architecture

This app follows **Clean Architecture** principles with clear separation between layers:

```
lib/
├── main.dart                           # App entry point
├── bindings/
│   └── initial_bindings.dart           # GetX dependency injection
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # API URLs, storage keys
│   ├── exceptions/
│   │   └── app_exceptions.dart         # Custom exception classes
│   └── network/
│       └── network_service.dart        # Connectivity monitoring
├── data/
│   ├── models/
│   │   └── github_user.dart            # Data models (User, UserDetail)
│   ├── datasources/
│   │   ├── github_api_service.dart     # Remote API calls
│   │   └── local_data_source.dart      # Local storage (SharedPreferences)
│   └── repositories/
│       └── user_repository.dart        # Repository pattern implementation
└── presentation/
    ├── controllers/
    │   ├── users_controller.dart       # Users list state management
    │   ├── favorites_controller.dart   # Favorites state management
    │   ├── user_detail_controller.dart # User detail state management
    │   └── navigation_controller.dart  # Bottom nav state
    ├── screens/
    │   ├── main_screen.dart            # Main screen with bottom navigation
    │   ├── home_screen.dart            # Users list screen
    │   ├── favorites_screen.dart       # Favorites screen
    │   └── user_detail_screen.dart     # User profile details
    └── widgets/
        ├── user_card.dart              # User list item widget
        ├── shimmer_widgets.dart        # Loading skeleton widgets
        ├── error_widget.dart           # Error state widgets
        └── empty_state_widget.dart     # Empty state widgets
```

### Layer Responsibilities

#### Data Layer
- **Models**: Data classes for GitHub users (`GitHubUser`, `GitHubUserDetail`)
- **Data Sources**: 
  - `GitHubApiService`: Handles all HTTP requests to GitHub API
  - `LocalDataSource`: Manages local storage for favorites and caching
- **Repository**: `UserRepository` combines remote and local data sources, handles offline fallback

#### Presentation Layer
- **Controllers**: GetX controllers for reactive state management
- **Screens**: UI screens for different app sections
- **Widgets**: Reusable UI components

#### Core Layer
- **Constants**: API endpoints, storage keys, configuration
- **Exceptions**: Custom exception types for error handling
- **Network**: Connectivity service for network state monitoring

## State Management

This app uses **GetX** for state management:

- Reactive state with `Rx` observables
- Dependency injection with `Get.put()` and `Get.find()`
- Navigation with `Get.to()` and `Get.back()`

## Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or later)
- Dart SDK (3.10.7 or later)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd Flutter-assignment
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `get` | State management, navigation, dependency injection |
| `http` | HTTP client for API requests |
| `cached_network_image` | Image caching and loading |
| `shared_preferences` | Local storage for favorites persistence |
| `connectivity_plus` | Network connectivity monitoring |
| `shimmer` | Loading skeleton animations |
| `url_launcher` | Opening URLs in browser |

## API

This app uses the [GitHub Users API](https://docs.github.com/en/rest/users):

| Endpoint | Description |
|----------|-------------|
| `GET /users` | List all users (paginated) |
| `GET /users/{username}` | Get user details |
| `GET /search/users` | Search users by query |

## Screens

### Home Screen
- Displays list of GitHub users
- Search bar with debounced input
- Pull-to-refresh support
- Infinite scroll pagination
- Favorite toggle button on each user

### Favorites Screen
- Displays all locally saved favorite users
- Swipe to remove from favorites
- Persists across app restarts

### Details Screen
- User profile with avatar
- Stats (repos, followers, following, gists)
- Additional info (company, location, blog, etc.)
- View on GitHub button
- Favorite toggle button

## Error Handling

The app handles various error scenarios:
- **No Internet**: Shows offline indicator, uses cached data when available
- **API Errors**: Displays error message with retry button
- **Rate Limiting**: Shows appropriate message for GitHub API rate limits
- **Empty States**: Shows helpful messages when lists are empty

## Bonus Features Implemented

- ✅ Search users with debounced API calls (500ms)
- ✅ Offline caching for users list
- ✅ Skeleton/shimmer loading UI
- ✅ Retry mechanism for failed API calls
- ✅ Unit and widget tests

## License

This project is for assignment purposes.
