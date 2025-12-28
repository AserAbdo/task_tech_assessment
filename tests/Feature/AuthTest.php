<?php

use App\Models\Task;
use App\Models\User;
use Tymon\JWTAuth\Facades\JWTAuth;

/*
|--------------------------------------------------------------------------
| Authentication Tests
|--------------------------------------------------------------------------
*/

describe('User Registration', function () {
    it('can register a new user', function () {
        $response = $this->postJson('/api/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'User registered successfully',
            ])
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'user' => ['id', 'name', 'email', 'created_at'],
                    'token',
                    'token_type',
                    'expires_in',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
            'name' => 'Test User',
        ]);
    });

    it('fails registration with invalid data', function () {
        $response = $this->postJson('/api/register', [
            'name' => '',
            'email' => 'invalid-email',
            'password' => '123', // Too short
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Validation failed',
            ]);
    });

    it('fails registration with duplicate email', function () {
        User::factory()->create(['email' => 'existing@example.com']);

        $response = $this->postJson('/api/register', [
            'name' => 'Test User',
            'email' => 'existing@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(422);
    });
});

describe('User Login', function () {
    it('can login with valid credentials', function () {
        $user = User::factory()->create([
            'email' => 'login@example.com',
            'password' => 'password123',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'login@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Login successful',
            ])
            ->assertJsonStructure([
                'data' => [
                    'user' => ['id', 'name', 'email'],
                    'token',
                    'token_type',
                    'expires_in',
                ],
            ]);
    });

    it('fails login with invalid credentials', function () {
        User::factory()->create([
            'email' => 'user@example.com',
            'password' => 'correctpassword',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'user@example.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'success' => false,
                'message' => 'Invalid credentials',
            ]);
    });
});

describe('Protected Routes', function () {
    it('can access protected routes with valid token', function () {
        $user = User::factory()->create();
        $token = JWTAuth::fromUser($user);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/me');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                    ],
                ],
            ]);
    });

    it('fails to access protected routes without token', function () {
        $response = $this->getJson('/api/me');

        $response->assertStatus(401);
    });

    it('can logout successfully', function () {
        $user = User::factory()->create();
        $token = JWTAuth::fromUser($user);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/logout');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Successfully logged out',
            ]);
    });
});
