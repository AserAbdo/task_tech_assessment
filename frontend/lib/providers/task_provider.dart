import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskStats {
  final int totalTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int doneTasks;

  TaskStats({
    this.totalTasks = 0,
    this.pendingTasks = 0,
    this.inProgressTasks = 0,
    this.doneTasks = 0,
  });
}

/// Provider for managing task state
class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  // Filters
  TaskStatus? _statusFilter;
  String? _searchQuery;

  // Stats
  TaskStats _stats = TaskStats();

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _currentPage < _lastPage;
  bool get hasMorePages => hasNextPage; // Alias for UI consistency
  bool get hasPreviousPage => _currentPage > 1;

  TaskStatus? get statusFilter => _statusFilter;
  String? get searchQuery => _searchQuery;

  TaskStats get stats => _stats;

  /// Load tasks from API
  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _tasks = []; // Clear tasks on refresh to show loading state cleanly
    }

    // If loading more pages, don't show full loading state, maybe just bottom loader
    if (_tasks.isEmpty) {
      _isLoading = true;
    }

    _error = null;
    notifyListeners();

    try {
      final result = await _taskService.getTasks(
        status: _statusFilter?.value,
        search: _searchQuery,
        page: _currentPage,
        perPage: 15,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      if (result.success && result.tasks != null) {
        if (refresh) {
          _tasks = result.tasks!;
        } else {
          _tasks.addAll(result.tasks!);
        }
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _total = result.total;
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load task statistics
  Future<void> loadStats() async {
    try {
      final result = await _taskService.getStats();
      if (result.success) {
        _stats = TaskStats(
          totalTasks: result.total,
          pendingTasks: result.pending,
          inProgressTasks: result.inProgress,
          doneTasks: result.done,
        );
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for stats
    }
  }

  /// Create a new task
  Future<bool> createTask({
    required String title,
    String? description,
    TaskStatus? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _taskService.createTask(
        title: title,
        description: description,
        status: status?.value,
      );

      if (result.success && result.task != null) {
        _tasks.insert(0, result.task!);
        _total++;
        await loadStats();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = result.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update a task
  Future<bool> updateTask({
    required int id,
    String? title,
    String? description,
    TaskStatus? status,
  }) async {
    _error = null;

    try {
      final result = await _taskService.updateTask(
        id: id,
        title: title,
        description: description,
        status: status?.value,
      );

      if (result.success && result.task != null) {
        final index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          _tasks[index] = result.task!;
        }
        await loadStats();
        notifyListeners();
        return true;
      }

      _error = result.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(int id) async {
    _error = null;

    try {
      final result = await _taskService.deleteTask(id);

      if (result.success) {
        _tasks.removeWhere((t) => t.id == id);
        _total--;
        await loadStats();
        notifyListeners();
        return true;
      }

      _error = result.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Set status filter
  void setStatusFilter(TaskStatus? status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      loadTasks(refresh: true);
    }
  }

  /// Set search query
  void setSearchQuery(String? query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadTasks(refresh: true);
    }
  }

  /// Clear all filters
  void clearFilters() {
    _statusFilter = null;
    _searchQuery = null;
    loadTasks(refresh: true);
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (hasNextPage && !_isLoading) {
      _currentPage++;
      await loadTasks();
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (hasPreviousPage && !_isLoading) {
      _currentPage--;
      await loadTasks();
    }
  }

  /// Clear state (on logout)
  void clear() {
    _tasks = [];
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _statusFilter = null;
    _searchQuery = null;
    _error = null;
    _stats = TaskStats();
    notifyListeners();
  }

  /// Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
