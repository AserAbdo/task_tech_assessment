import '../models/task.dart';
import 'api_service.dart';

/// Service for handling task operations
class TaskService {
  final ApiService _apiService = ApiService();

  /// Get all tasks for the authenticated user
  Future<TaskListResult> getTasks({
    String? status,
    String? search,
    int? page,
    int? perPage,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _apiService.get(
        '/tasks',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final tasksJson = data['tasks'] as List;
        final tasks = tasksJson
            .map((json) => Task.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return TaskListResult(
          success: true,
          tasks: tasks,
          currentPage: pagination?['current_page'] as int? ?? 1,
          lastPage: pagination?['last_page'] as int? ?? 1,
          total: pagination?['total'] as int? ?? tasks.length,
        );
      }

      return TaskListResult(
        success: false,
        message: response['message'] ?? 'Failed to load tasks',
      );
    } on ApiException catch (e) {
      return TaskListResult(success: false, message: e.message);
    }
  }

  /// Get task statistics
  Future<TaskStatsResult> getStats() async {
    try {
      final response = await _apiService.get('/tasks/stats');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final stats = data['stats'] as Map<String, dynamic>;

        return TaskStatsResult(
          success: true,
          total: stats['total'] as int? ?? 0,
          pending: stats['pending'] as int? ?? 0,
          inProgress: stats['in_progress'] as int? ?? 0,
          done: stats['done'] as int? ?? 0,
        );
      }

      return TaskStatsResult(success: false, message: 'Failed to load stats');
    } on ApiException catch (e) {
      return TaskStatsResult(success: false, message: e.message);
    }
  }

  /// Create a new task
  Future<TaskResult> createTask({
    required String title,
    String? description,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{'title': title};
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (status != null) {
        data['status'] = status;
      }

      final response = await _apiService.post('/tasks', data: data);

      if (response['success'] == true) {
        final taskData = response['data']['task'] as Map<String, dynamic>;
        final task = Task.fromJson(taskData);

        return TaskResult(
          success: true,
          task: task,
          message: 'Task created successfully',
        );
      }

      return TaskResult(
        success: false,
        message: response['message'] ?? 'Failed to create task',
      );
    } on ApiException catch (e) {
      return TaskResult(success: false, message: e.message, errors: e.errors);
    }
  }

  /// Update an existing task
  Future<TaskResult> updateTask({
    required int id,
    String? title,
    String? description,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (status != null) data['status'] = status;

      final response = await _apiService.put('/tasks/$id', data: data);

      if (response['success'] == true) {
        final taskData = response['data']['task'] as Map<String, dynamic>;
        final task = Task.fromJson(taskData);

        return TaskResult(
          success: true,
          task: task,
          message: 'Task updated successfully',
        );
      }

      return TaskResult(
        success: false,
        message: response['message'] ?? 'Failed to update task',
      );
    } on ApiException catch (e) {
      return TaskResult(success: false, message: e.message, errors: e.errors);
    }
  }

  /// Delete a task
  Future<TaskResult> deleteTask(int id) async {
    try {
      final response = await _apiService.delete('/tasks/$id');

      if (response['success'] == true) {
        return TaskResult(success: true, message: 'Task deleted successfully');
      }

      return TaskResult(
        success: false,
        message: response['message'] ?? 'Failed to delete task',
      );
    } on ApiException catch (e) {
      return TaskResult(success: false, message: e.message);
    }
  }
}

/// Result class for task list operations
class TaskListResult {
  final bool success;
  final List<Task>? tasks;
  final String? message;
  final int currentPage;
  final int lastPage;
  final int total;

  TaskListResult({
    required this.success,
    this.tasks,
    this.message,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });
}

/// Result class for single task operations
class TaskResult {
  final bool success;
  final Task? task;
  final String? message;
  final Map<String, dynamic>? errors;

  TaskResult({required this.success, this.task, this.message, this.errors});
}

/// Result class for task statistics
class TaskStatsResult {
  final bool success;
  final int total;
  final int pending;
  final int inProgress;
  final int done;
  final String? message;

  TaskStatsResult({
    required this.success,
    this.total = 0,
    this.pending = 0,
    this.inProgress = 0,
    this.done = 0,
    this.message,
  });
}
