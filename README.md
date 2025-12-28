# Task Management API

A RESTful API backend for a Task Management Application built with Laravel 12 and JWT authentication.

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Authentication Flow](#authentication-flow)
- [Testing](#testing)
- [Project Structure](#project-structure)

## ✨ Features

- **JWT Authentication**: Secure token-based authentication using `tymon/jwt-auth`
- **User Registration & Login**: Complete auth system with token refresh
- **Task CRUD Operations**: Create, Read, Update, Delete tasks
- **Task Filtering & Search**: Filter by status, search by title
- **Pagination**: Configurable pagination for task listing
- **User Isolation**: Users can only access their own tasks
- **CORS Support**: Configured for Flutter Web frontend integration
- **Comprehensive Validation**: Request validation with detailed error messages
- **API Tests**: Full test coverage using Pest PHP

## 📸 Screenshots

| Task Dashboard |
|:---:|
| ![Task Dashboard](screenshots/home.png) |

| Login Screen | Registration Screen |
|:---:|:---:|
| ![Login Screen](screenshots/login.png) | ![Registration Screen](screenshots/signup.png) |

## 📦 Requirements

- PHP >= 8.2
- Composer
- MySQL 8.0+ or SQLite
- Node.js & NPM (for development tools)

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd task_tech_assessment
```

### 2. Install Dependencies

```bash
composer install
```

### 3. Environment Setup

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Generate JWT secret key
php artisan jwt:secret
```

### 4. Configure Environment Variables

Edit the `.env` file and set your database credentials:

```env
# For MySQL
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=task_management
DB_USERNAME=root
DB_PASSWORD=your_password

# Or for SQLite (simpler setup)
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
```

## 🗄️ Database Setup

### Option 1: MySQL

```bash
# Create the database
mysql -u root -p -e "CREATE DATABASE task_management;"

# Run migrations
php artisan migrate

# (Optional) Seed with dummy data
php artisan db:seed
```

### Option 2: SQLite

```bash
# Create the SQLite database file
touch database/database.sqlite

# Run migrations
php artisan migrate

# (Optional) Seed with dummy data
php artisan db:seed
```

### Demo Credentials (After Seeding)

```
Email: demo@example.com
Password: password123
```

## 🏃 Running the Application

```bash
# Start the development server
php artisan serve
```

The API will be available at `http://localhost:8000`

### Health Check

```bash
curl http://localhost:8000/api/health
```

## 📖 API Documentation

### Base URL

```
http://localhost:8000/api
```

### Response Format

All responses follow this structure:

```json
{
    "success": true|false,
    "message": "Response message",
    "data": { ... },
    "errors": { ... }  // Only on validation errors
}
```

---

### 🔐 Authentication Endpoints

#### Register User

```http
POST /api/register
```

**Request Body:**
```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
}
```

**Response (201 Created):**
```json
{
    "success": true,
    "message": "User registered successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "created_at": "2024-12-28T19:24:00.000000Z"
        },
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "token_type": "bearer",
        "expires_in": 3600
    }
}
```

---

#### Login User

```http
POST /api/login
```

**Request Body:**
```json
{
    "email": "john@example.com",
    "password": "password123"
}
```

**Response (200 OK):**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "created_at": "2024-12-28T19:24:00.000000Z"
        },
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "token_type": "bearer",
        "expires_in": 3600
    }
}
```

---

#### Get Current User

```http
GET /api/me
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "created_at": "2024-12-28T19:24:00.000000Z"
        }
    }
}
```

---

#### Logout

```http
POST /api/logout
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
    "success": true,
    "message": "Successfully logged out"
}
```

---

#### Refresh Token

```http
POST /api/refresh
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
    "success": true,
    "message": "Token refreshed successfully",
    "data": {
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "token_type": "bearer",
        "expires_in": 3600
    }
}
```

---

### 📝 Task Endpoints

> **Note:** All task endpoints require authentication. Include the `Authorization: Bearer {token}` header.

#### List Tasks

```http
GET /api/tasks
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Filter by status: `pending`, `in_progress`, `done` |
| `search` | string | Search in task titles |
| `per_page` | integer | Items per page (default: 15, max: 100) |
| `page` | integer | Page number |
| `sort_by` | string | Sort field: `title`, `status`, `created_at`, `updated_at` |
| `sort_order` | string | Sort order: `asc`, `desc` |

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/tasks?status=pending&per_page=10" \
  -H "Authorization: Bearer {token}"
```

**Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "tasks": [
            {
                "id": 1,
                "user_id": 1,
                "title": "Complete project documentation",
                "description": "Write comprehensive API docs",
                "status": "pending",
                "created_at": "2024-12-28T19:24:00.000000Z",
                "updated_at": "2024-12-28T19:24:00.000000Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 2,
            "per_page": 10,
            "total": 15,
            "from": 1,
            "to": 10
        }
    }
}
```

---

#### Create Task

```http
POST /api/tasks
Authorization: Bearer {token}
```

**Request Body:**
```json
{
    "title": "New Task",
    "description": "Optional task description",
    "status": "pending"
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `title` | Yes | string | Task title (max 255 chars) |
| `description` | No | string | Task description (max 1000 chars) |
| `status` | No | string | `pending` (default), `in_progress`, `done` |

**Response (201 Created):**
```json
{
    "success": true,
    "message": "Task created successfully",
    "data": {
        "task": {
            "id": 1,
            "user_id": 1,
            "title": "New Task",
            "description": "Optional task description",
            "status": "pending",
            "created_at": "2024-12-28T19:24:00.000000Z",
            "updated_at": "2024-12-28T19:24:00.000000Z"
        }
    }
}
```

---

#### Get Single Task

```http
GET /api/tasks/{id}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "task": {
            "id": 1,
            "user_id": 1,
            "title": "Task Title",
            "description": "Task description",
            "status": "pending",
            "created_at": "2024-12-28T19:24:00.000000Z",
            "updated_at": "2024-12-28T19:24:00.000000Z"
        }
    }
}
```

---

#### Update Task

```http
PUT /api/tasks/{id}
Authorization: Bearer {token}
```

**Request Body (all fields optional):**
```json
{
    "title": "Updated Title",
    "description": "Updated description",
    "status": "done"
}
```

**Response (200 OK):**
```json
{
    "success": true,
    "message": "Task updated successfully",
    "data": {
        "task": {
            "id": 1,
            "user_id": 1,
            "title": "Updated Title",
            "description": "Updated description",
            "status": "done",
            "created_at": "2024-12-28T19:24:00.000000Z",
            "updated_at": "2024-12-28T19:30:00.000000Z"
        }
    }
}
```

---

#### Delete Task

```http
DELETE /api/tasks/{id}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
    "success": true,
    "message": "Task deleted successfully"
}
```

---

#### Get Task Statistics

```http
GET /api/tasks/stats
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "stats": {
            "total": 15,
            "pending": 5,
            "in_progress": 3,
            "done": 7
        }
    }
}
```

---

### ❌ Error Responses

#### Validation Error (422)
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "title": ["The title field is required."],
        "status": ["The selected status is invalid."]
    }
}
```

#### Unauthorized (401)
```json
{
    "message": "Unauthenticated."
}
```

#### Not Found (404)
```json
{
    "success": false,
    "message": "Task not found"
}
```

---

## 🔒 Authentication Flow

### 1. Register or Login
Make a POST request to `/api/register` or `/api/login` to obtain a JWT token.

### 2. Store the Token
Store the received token securely in your frontend application.

### 3. Include Token in Requests
Add the token to the `Authorization` header for all protected endpoints:
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

### 4. Token Refresh
Tokens expire after 60 minutes (configurable via `JWT_TTL`). Use the `/api/refresh` endpoint to get a new token before expiration.

### 5. Logout
Call `/api/logout` to invalidate the current token.

### Token Expiration Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `JWT_TTL` | 60 | Token lifetime in minutes |
| `JWT_REFRESH_TTL` | 20160 | Refresh window in minutes (14 days) |

---

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
php artisan test

# Run with coverage
php artisan test --coverage

# Run specific test file
php artisan test tests/Feature/AuthTest.php
php artisan test tests/Feature/TaskTest.php
```

---

## 📂 Project Structure

```
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       └── Api/
│   │           ├── AuthController.php    # Authentication endpoints
│   │           └── TaskController.php    # Task CRUD operations
│   └── Models/
│       ├── User.php                      # User model with JWT
│       └── Task.php                      # Task model
├── config/
│   ├── auth.php                          # Auth guards (JWT)
│   ├── cors.php                          # CORS configuration
│   └── jwt.php                           # JWT settings
├── database/
│   ├── factories/
│   │   ├── UserFactory.php
│   │   └── TaskFactory.php
│   ├── migrations/
│   │   ├── ..._create_users_table.php
│   │   └── ..._create_tasks_table.php
│   └── seeders/
│       └── DatabaseSeeder.php
├── routes/
│   └── api.php                           # API routes
├── tests/
│   └── Feature/
│       ├── AuthTest.php                  # Auth tests
│       └── TaskTest.php                  # Task tests
├── .env.example                          # Environment template
└── README.md                             # This file
```

---

## 🔧 Configuration Options

### CORS (config/cors.php)

Update `FRONTEND_URL` in `.env` to match your Flutter Web app URL:

```env
FRONTEND_URL=http://localhost:3000
```

### JWT Settings

Modify JWT settings in `.env`:

```env
JWT_TTL=60           # Token lifetime in minutes
JWT_REFRESH_TTL=20160 # Refresh window (14 days)
```

---

## 📄 License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
