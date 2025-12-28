<?php

namespace Database\Seeders;

use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create a demo user with known credentials
        $demoUser = User::factory()->create([
            'name' => 'Demo User',
            'email' => 'demo@example.com',
            'password' => 'password123', // Will be hashed automatically
        ]);

        // Create tasks for the demo user
        Task::factory()
            ->count(5)
            ->pending()
            ->forUser($demoUser)
            ->create();

        Task::factory()
            ->count(3)
            ->inProgress()
            ->forUser($demoUser)
            ->create();

        Task::factory()
            ->count(7)
            ->done()
            ->forUser($demoUser)
            ->create();

        // Create additional test users with random tasks
        $testUsers = User::factory()
            ->count(3)
            ->create();

        foreach ($testUsers as $user) {
            Task::factory()
                ->count(rand(5, 15))
                ->forUser($user)
                ->create();
        }

        $this->command->info('Database seeded successfully!');
        $this->command->info('Demo user credentials:');
        $this->command->info('Email: demo@example.com');
        $this->command->info('Password: password123');
    }
}
