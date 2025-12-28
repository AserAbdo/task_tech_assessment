<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TaskController extends Controller
{
    /**
     * Display a listing of the user's tasks.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = auth()->user()->tasks();

            // Filter by status if provided
            if ($request->has('status') && in_array($request->status, Task::getStatuses())) {
                $query->withStatus($request->status);
            }

            // Search by title if provided
            if ($request->has('search') && !empty($request->search)) {
                $query->where('title', 'like', '%' . $request->search . '%');
            }

            // Sort by field (default: created_at)
            $sortField = $request->get('sort_by', 'created_at');
            $sortOrder = $request->get('sort_order', 'desc');
            
            $allowedSortFields = ['title', 'status', 'created_at', 'updated_at'];
            if (in_array($sortField, $allowedSortFields)) {
                $query->orderBy($sortField, $sortOrder === 'asc' ? 'asc' : 'desc');
            }

            // Pagination
            $perPage = min($request->get('per_page', 15), 100); // Max 100 per page
            $tasks = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => [
                    'tasks' => $tasks->items(),
                    'pagination' => [
                        'current_page' => $tasks->currentPage(),
                        'last_page' => $tasks->lastPage(),
                        'per_page' => $tasks->perPage(),
                        'total' => $tasks->total(),
                        'from' => $tasks->firstItem(),
                        'to' => $tasks->lastItem(),
                    ]
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch tasks',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created task.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'status' => 'nullable|string|in:' . implode(',', Task::getStatuses()),
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $task = auth()->user()->tasks()->create([
                'title' => $request->title,
                'description' => $request->description,
                'status' => $request->status ?? Task::STATUS_PENDING,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Task created successfully',
                'data' => [
                    'task' => $task
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create task',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified task.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        try {
            $task = auth()->user()->tasks()->find($id);

            if (!$task) {
                return response()->json([
                    'success' => false,
                    'message' => 'Task not found'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'task' => $task
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch task',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified task.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'status' => 'sometimes|string|in:' . implode(',', Task::getStatuses()),
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $task = auth()->user()->tasks()->find($id);

            if (!$task) {
                return response()->json([
                    'success' => false,
                    'message' => 'Task not found'
                ], 404);
            }

            $updateData = [];
            
            if ($request->has('title')) {
                $updateData['title'] = $request->title;
            }
            
            if ($request->has('description')) {
                $updateData['description'] = $request->description;
            }
            
            if ($request->has('status')) {
                $updateData['status'] = $request->status;
            }

            $task->update($updateData);

            return response()->json([
                'success' => true,
                'message' => 'Task updated successfully',
                'data' => [
                    'task' => $task->fresh()
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update task',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified task.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(int $id): JsonResponse
    {
        try {
            $task = auth()->user()->tasks()->find($id);

            if (!$task) {
                return response()->json([
                    'success' => false,
                    'message' => 'Task not found'
                ], 404);
            }

            $task->delete();

            return response()->json([
                'success' => true,
                'message' => 'Task deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete task',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get task statistics for the authenticated user.
     *
     * @return JsonResponse
     */
    public function stats(): JsonResponse
    {
        try {
            $user = auth()->user();
            
            $stats = [
                'total' => $user->tasks()->count(),
                'pending' => $user->tasks()->withStatus(Task::STATUS_PENDING)->count(),
                'in_progress' => $user->tasks()->withStatus(Task::STATUS_IN_PROGRESS)->count(),
                'done' => $user->tasks()->withStatus(Task::STATUS_DONE)->count(),
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'stats' => $stats
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch task statistics',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
