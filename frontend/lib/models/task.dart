/// Enum representing task status
enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  done('done', 'Done');

  final String value;
  final String displayName;

  const TaskStatus(this.value, this.displayName);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

/// Task model representing a user's task
class Task {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, status: ${status.displayName})';
}
