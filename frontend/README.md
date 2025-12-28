# Task Management - Flutter Web Frontend

A modern, responsive Flutter Web application for managing tasks. This frontend connects to the Laravel API backend.

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Screenshots](#screenshots)
- [State Management](#state-management)
- [API Integration](#api-integration)

## ✨ Features

- **Premium UI/UX**
  - Modern, clean interface with Indigo/Violet color scheme
  - Responsive dashboard layout with statistics
  - Smooth animations and transitions
  - Google Fonts (Inter) for professional typography
  - Interactive states and feedback

- **Authentication**
  - Beautiful login & registration screens
  - Form validation with real-time feedback
  - Secure JWT token management
  - Auto-login persistence

- **Task Management**
  - **Dashboard View**: Real-time statistics (Total, Pending, In Progress, Done)
  - **Smart Filtering**: Filter by status and search by title
  - **CRUD Operations**: Create, Read, Update, Delete tasks seamlessly
  - **Pagination**: Infinite scroll support for large task lists
  - **Empty States**: Helpful illustrations when no tasks are found

## 📦 Requirements

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Chrome browser (for web testing)
- Laravel backend running on http://127.0.0.1:8000

## 🚀 Installation

### 1. Navigate to the frontend directory

```bash
cd frontend
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Verify Flutter setup

```bash
flutter doctor
```

Ensure Chrome is listed and available for web development.

## 🏃 Running the Application

### Development Mode

```bash
# Run on Chrome
flutter run -d chrome

# Run on Chrome with specific port
flutter run -d chrome --web-port=3000
```

### Build for Production

```bash
# Build web release
flutter build web

# The built files will be in build/web/
```

### Important: Start the Backend First!

Make sure the Laravel backend is running before starting the Flutter app:

```bash
# In the project root directory
cd ..
php artisan serve
```

The API should be available at `http://127.0.0.1:8000`

## 📂 Project Structure

```
frontend/
├── lib/
│   ├── main.dart                 # App entry point & theme
│   ├── models/
│   │   ├── user.dart             # User model
│   │   └── task.dart             # Task model with TaskStatus enum
│   ├── services/
│   │   ├── api_service.dart      # Dio HTTP client & token management
│   │   ├── auth_service.dart     # Authentication operations
│   │   └── task_service.dart     # Task CRUD operations
│   ├── providers/
│   │   ├── auth_provider.dart    # Authentication state
│   │   └── task_provider.dart    # Task state management
│   ├── screens/
│   │   ├── login_screen.dart     # Login page
│   │   ├── register_screen.dart  # Registration page
│   │   └── tasks_screen.dart     # Main tasks page
│   └── widgets/
│       ├── task_card.dart        # Task display card
│       └── task_form.dart        # Create/Edit task dialog
├── web/
│   └── index.html                # HTML template
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## ⚙️ Configuration

### API Base URL

The API URL is configured in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

To change it, update this line with your backend URL.

### For Production

When deploying, update the `baseUrl` to your production API URL:

```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

## 🖼️ Screenshots
(Screenshots would go here)

### Login Screen
- Modern centered card design
- Clean typography and spacing
- Demo credentials hint for easy testing

### Dashboard (Tasks Screen)
- **Stats Bar**: Visual overview of task counts
- **Search & Filter**: Integrated search bar and status dropdown
- **Task List**: Beautiful cards with status badges and actions
- **Responsive**: Adapts to different screen sizes

### Task Form
- Clean dialog for creating and editing tasks
- Validation with visual feedback
- Status selection with icons

## 🔄 State Management

This app uses **Provider** for state management:

### AuthProvider
- Manages user authentication state
- Handles login, register, logout operations
- Persists authentication across app restarts
- Provides loading and error states

### TaskProvider
- Manages tasks list and operations
- Handles CRUD operations
- Manages filters (status, search)
- Provides pagination state
- Tracks task statistics

### Usage Example

```dart
// Read provider (no rebuilds)
final authProvider = context.read<AuthProvider>();
await authProvider.login(email: email, password: password);

// Watch provider (rebuilds on change)
final taskProvider = context.watch<TaskProvider>();
final tasks = taskProvider.tasks;
```

## 🔌 API Integration

### Endpoints Used

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | User registration |
| POST | `/login` | User login |
| GET | `/me` | Get current user |
| POST | `/logout` | Logout user |
| GET | `/tasks` | List tasks (with filters) |
| POST | `/tasks` | Create task |
| PUT | `/tasks/{id}` | Update task |
| DELETE | `/tasks/{id}` | Delete task |
| GET | `/tasks/stats` | Get task statistics |

### Authentication

JWT tokens are:
- Stored in SharedPreferences (persistent)
- Automatically added to API requests via Dio interceptor
- Cleared on logout

### Error Handling

- Network errors display user-friendly messages
- Validation errors from API are parsed and displayed
- 401 responses trigger automatic logout

## 🛠️ Dependencies

```yaml
dependencies:
  flutter: sdk
  dio: ^5.4.0              # HTTP client
  provider: ^6.1.1         # State management
  shared_preferences: ^2.2.2  # Local storage
  intl: ^0.19.0            # Date formatting
  google_fonts: ^6.1.0     # Typography
```

## 🐛 Troubleshooting

### CORS Issues
If you get CORS errors, ensure the Laravel backend has CORS configured properly. Check `config/cors.php` in the backend.

### Connection Refused
Make sure the Laravel backend is running on `http://127.0.0.1:8000`. Check that you're using the correct IP/port.

### Hot Reload Not Working
Try restarting the Flutter app with:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## 📄 License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
