<?php

namespace Database\Factories;

use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Task>
 */
class TaskFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = Task::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $tasks = [
            ['title' => 'Design homepage UI', 'description' => 'Create a modern and responsive design for the application homepage using Figma.'],
            ['title' => 'Implement authentication', 'description' => 'Setup JWT authentication with login, register, and password reset functionality.'],
            ['title' => 'Fix navigation bug', 'description' => 'Resolve the issue where the mobile menu does not close after clicking a link.'],
            ['title' => 'Optimize database queries', 'description' => 'Analyze and index the database tables to improve query performance for the dashboard.'],
            ['title' => 'Write API documentation', 'description' => 'Document all API endpoints using Swagger/OpenAPI for better developer experience.'],
            ['title' => 'Setup CI/CD pipeline', 'description' => 'Configure GitHub Actions to automatically run tests and deploy to the staging server.'],
            ['title' => 'Conduct user interviews', 'description' => 'Schedule and conduct interviews with 5 potential users to gather feedback on the prototype.'],
            ['title' => 'Refactor legacy code', 'description' => 'Clean up the user controller and move logic to service classes for better maintainability.'],
            ['title' => 'Update dependencies', 'description' => 'Upgrade Laravel and Node.js packages to their latest stable versions.'],
            ['title' => 'Create marketing assets', 'description' => 'Design banners and social media posts for the upcoming product launch.'],
            ['title' => 'Review pull requests', 'description' => 'Review pending code changes from the team and provide constructive feedback.'],
            ['title' => 'Prepare monthly report', 'description' => 'Compile usage statistics and performance metrics for the monthly management meeting.'],
        ];
        
        $task = fake()->randomElement($tasks);

        return [
            'user_id' => User::factory(),
            'title' => $task['title'],
            'description' => $task['description'],
            'status' => fake()->randomElement(Task::getStatuses()),
            'created_at' => fake()->dateTimeBetween('-30 days', 'now'),
            'updated_at' => function (array $attributes) {
                return fake()->dateTimeBetween($attributes['created_at'], 'now');
            },
        ];
    }

    /**
     * Indicate that the task is pending.
     */
    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Task::STATUS_PENDING,
        ]);
    }

    /**
     * Indicate that the task is in progress.
     */
    public function inProgress(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Task::STATUS_IN_PROGRESS,
        ]);
    }

    /**
     * Indicate that the task is done.
     */
    public function done(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Task::STATUS_DONE,
        ]);
    }

    /**
     * Indicate that the task belongs to a specific user.
     */
    public function forUser(User $user): static
    {
        return $this->state(fn (array $attributes) => [
            'user_id' => $user->id,
        ]);
    }
}
