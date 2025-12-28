<?php

use App\Models\Task;
use App\Models\User;
use Tymon\JWTAuth\Facades\JWTAuth;

/*
|--------------------------------------------------------------------------
| Task Management Tests
|--------------------------------------------------------------------------
*/

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = JWTAuth::fromUser($this->user);
    $this->headers = ['Authorization' => 'Bearer ' . $this->token];
});

describe('Task Creation', function () {
    it('can create a task', function () {
        $response = $this->withHeaders($this->headers)->postJson('/api/tasks', [
            'title' => 'Test Task',
            'description' => 'Test Description',
            'status' => 'pending',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Task created successfully',
            ])
            ->assertJsonStructure([
                'data' => [
                    'task' => ['id', 'title', 'description', 'status', 'created_at', 'updated_at'],
                ],
            ]);

        $this->assertDatabaseHas('tasks', [
            'user_id' => $this->user->id,
            'title' => 'Test Task',
            'status' => 'pending',
        ]);
    });

    it('creates task with default pending status', function () {
        $response = $this->withHeaders($this->headers)->postJson('/api/tasks', [
            'title' => 'Task Without Status',
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('tasks', [
            'title' => 'Task Without Status',
            'status' => 'pending',
        ]);
    });

    it('fails to create task without title', function () {
        $response = $this->withHeaders($this->headers)->postJson('/api/tasks', [
            'description' => 'No title provided',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'Validation failed',
            ]);
    });

    it('fails to create task with invalid status', function () {
        $response = $this->withHeaders($this->headers)->postJson('/api/tasks', [
            'title' => 'Task',
            'status' => 'invalid_status',
        ]);

        $response->assertStatus(422);
    });
});

describe('Task Listing', function () {
    it('can list user tasks', function () {
        Task::factory()->count(5)->forUser($this->user)->create();

        $response = $this->withHeaders($this->headers)->getJson('/api/tasks');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'data' => [
                    'tasks',
                    'pagination' => [
                        'current_page',
                        'last_page',
                        'per_page',
                        'total',
                    ],
                ],
            ]);

        expect($response->json('data.pagination.total'))->toBe(5);
    });

    it('only shows tasks belonging to authenticated user', function () {
        // Create tasks for the authenticated user
        Task::factory()->count(3)->forUser($this->user)->create();

        // Create tasks for another user
        $otherUser = User::factory()->create();
        Task::factory()->count(5)->forUser($otherUser)->create();

        $response = $this->withHeaders($this->headers)->getJson('/api/tasks');

        expect($response->json('data.pagination.total'))->toBe(3);
    });

    it('can filter tasks by status', function () {
        Task::factory()->count(3)->pending()->forUser($this->user)->create();
        Task::factory()->count(2)->done()->forUser($this->user)->create();

        $response = $this->withHeaders($this->headers)->getJson('/api/tasks?status=pending');

        expect($response->json('data.pagination.total'))->toBe(3);
    });

    it('can search tasks by title', function () {
        Task::factory()->forUser($this->user)->create(['title' => 'Important Meeting']);
        Task::factory()->forUser($this->user)->create(['title' => 'Regular Task']);
        Task::factory()->forUser($this->user)->create(['title' => 'Another Important Item']);

        $response = $this->withHeaders($this->headers)->getJson('/api/tasks?search=Important');

        expect($response->json('data.pagination.total'))->toBe(2);
    });

    it('supports pagination', function () {
        Task::factory()->count(25)->forUser($this->user)->create();

        $response = $this->withHeaders($this->headers)->getJson('/api/tasks?per_page=10');

        expect($response->json('data.pagination.per_page'))->toBe(10);
        expect($response->json('data.pagination.last_page'))->toBe(3);
    });
});

describe('Task Retrieval', function () {
    it('can get a single task', function () {
        $task = Task::factory()->forUser($this->user)->create();

        $response = $this->withHeaders($this->headers)->getJson("/api/tasks/{$task->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'task' => [
                        'id' => $task->id,
                        'title' => $task->title,
                    ],
                ],
            ]);
    });

    it('returns 404 for non-existent task', function () {
        $response = $this->withHeaders($this->headers)->getJson('/api/tasks/99999');

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Task not found',
            ]);
    });

    it('cannot access another user task', function () {
        $otherUser = User::factory()->create();
        $task = Task::factory()->forUser($otherUser)->create();

        $response = $this->withHeaders($this->headers)->getJson("/api/tasks/{$task->id}");

        $response->assertStatus(404);
    });
});

describe('Task Update', function () {
    it('can update a task', function () {
        $task = Task::factory()->pending()->forUser($this->user)->create();

        $response = $this->withHeaders($this->headers)->putJson("/api/tasks/{$task->id}", [
            'title' => 'Updated Title',
            'status' => 'done',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Task updated successfully',
            ]);

        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'title' => 'Updated Title',
            'status' => 'done',
        ]);
    });

    it('can partially update a task', function () {
        $task = Task::factory()->forUser($this->user)->create([
            'title' => 'Original Title',
            'description' => 'Original Description',
        ]);

        $response = $this->withHeaders($this->headers)->putJson("/api/tasks/{$task->id}", [
            'title' => 'New Title',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'title' => 'New Title',
            'description' => 'Original Description', // Unchanged
        ]);
    });

    it('cannot update another user task', function () {
        $otherUser = User::factory()->create();
        $task = Task::factory()->forUser($otherUser)->create();

        $response = $this->withHeaders($this->headers)->putJson("/api/tasks/{$task->id}", [
            'title' => 'Hacked Title',
        ]);

        $response->assertStatus(404);
    });
});

describe('Task Deletion', function () {
    it('can delete a task', function () {
        $task = Task::factory()->forUser($this->user)->create();

        $response = $this->withHeaders($this->headers)->deleteJson("/api/tasks/{$task->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Task deleted successfully',
            ]);

        $this->assertDatabaseMissing('tasks', [
            'id' => $task->id,
        ]);
    });

    it('cannot delete another user task', function () {
        $otherUser = User::factory()->create();
        $task = Task::factory()->forUser($otherUser)->create();

        $response = $this->withHeaders($this->headers)->deleteJson("/api/tasks/{$task->id}");

        $response->assertStatus(404);

        // Task should still exist
        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
        ]);
    });
});

describe('Task Statistics', function () {
    it('can get task statistics', function () {
        Task::factory()->count(3)->pending()->forUser($this->user)->create();
        Task::factory()->count(2)->inProgress()->forUser($this->user)->create();
        Task::factory()->count(5)->done()->forUser($this->user)->create();

        $response = $this->withHeaders($this->headers)->getJson('/api/tasks/stats');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'stats' => [
                        'total' => 10,
                        'pending' => 3,
                        'in_progress' => 2,
                        'done' => 5,
                    ],
                ],
            ]);
    });
});
