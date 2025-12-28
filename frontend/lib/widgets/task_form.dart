import 'package:flutter/material.dart';
import '../models/task.dart';

/// Dialog/Form widget for creating or editing a task
class TaskFormDialog extends StatefulWidget {
  final Task? task; // null for create, non-null for edit
  final Function(String title, String? description, TaskStatus status) onSubmit;

  const TaskFormDialog({super.key, this.task, required this.onSubmit});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskStatus _selectedStatus;
  bool _isLoading = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedStatus = widget.task?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Call the callback
      await widget.onSubmit(
        _titleController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _selectedStatus,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isEditing ? 'Edit Task' : 'Create New Task',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'What needs to be done?',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add some details...',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                // Status dropdown
                DropdownButtonFormField<TaskStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            size: 16,
                            color: _getStatusColor(status),
                          ),
                          const SizedBox(width: 8),
                          Text(status.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEditing ? 'Save Changes' : 'Create Task'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule_rounded;
      case TaskStatus.inProgress:
        return Icons.sync_rounded;
      case TaskStatus.done:
        return Icons.check_circle_outline_rounded;
    }
  }
}
