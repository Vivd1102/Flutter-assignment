# GitHub Users App

A Flutter application that uses the GitHub Users API to display and search GitHub users.

## Features

- 📋 **Users List** - Browse GitHub users with infinite scroll pagination
- 🔍 **Search** - Search for users by username
- 👤 **User Details** - View detailed profile information including:
  - Avatar, name, and bio
  - Public repos, followers, following, and gists count
  - Company, location, email, and website
  - Join date
- 🔗 **GitHub Link** - Open user profiles directly on GitHub
- 🎨 **Material 3** - Modern UI with light/dark theme support
- 📱 **Pull to Refresh** - Refresh the users list

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── github_user.dart         # User data models
├── services/
│   └── github_api_service.dart  # GitHub API client
├── providers/
│   └── users_provider.dart      # State management
├── screens/
│   ├── users_list_screen.dart   # Main users list
│   └── user_detail_screen.dart  # User profile details
└── widgets/
    └── user_card.dart           # User list item widget
```

## Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or later)
- Dart SDK (3.10.7 or later)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **http** - HTTP client for API requests
- **provider** - State management
- **cached_network_image** - Image caching and loading
- **url_launcher** - Opening URLs in browser

## API

This app uses the [GitHub Users API](https://docs.github.com/en/rest/users):

- `GET /users` - List all users
- `GET /users/{username}` - Get user details
- `GET /search/users` - Search users
