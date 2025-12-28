import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

/// Card widget to display a single task
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(TaskStatus)? onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.onStatusChange,
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange.shade500;
      case TaskStatus.inProgress:
        return Colors.blue.shade500;
      case TaskStatus.done:
        return Colors.green.shade500;
    }
  }

  Color _getStatusBgColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange.shade50;
      case TaskStatus.inProgress:
        return Colors.blue.shade50;
      case TaskStatus.done:
        return Colors.green.shade50;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule_rounded;
      case TaskStatus.inProgress:
        return Icons.sync_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final statusColor = _getStatusColor(task.status);
    final statusBgColor = _getStatusBgColor(task.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(task.status),
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                task.status.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: task.status == TaskStatus.done
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.status == TaskStatus.done
                                    ? Colors.grey[400]
                                    : const Color(0xFF111827),
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Actions Menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.grey[400],
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete Task',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 16),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(task.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),

                  // Status Dropdown (Mini)
                  if (onStatusChange != null)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TaskStatus>(
                          value: task.status,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (TaskStatus? newValue) {
                            if (newValue != null) {
                              onStatusChange!(newValue);
                            }
                          },
                          items: TaskStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
