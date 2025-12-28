import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';
import 'login_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      context.read<TaskProvider>().loadStats();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskProvider>().nextPage();
    }
  }

  void _showTaskForm({Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        task: task,
        onSubmit: (title, description, status) async {
          final provider = context.read<TaskProvider>();
          bool success;
          
          if (task == null) {
            // Create
            success = await provider.createTask(
              title: title,
              description: description,
              status: status,
            );
          } else {
            // Update
            success = await provider.updateTask(
              id: task.id,
              title: title,
              description: description,
              status: status,
            );
          }

          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.error ?? 'Operation failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Task Manager'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<TaskProvider>().loadTasks(refresh: true);
              context.read<TaskProvider>().loadStats();
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                context.read<AuthProvider>().user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.read<AuthProvider>().user?.name ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      context.read<AuthProvider>().user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Stats & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Stats Row
                Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    final stats = provider.stats;
                    return Row(
                      children: [
                        _buildStatCard(
                          context,
                          'Total',
                          stats.totalTasks.toString(),
                          Colors.purple,
                          Icons.assignment_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          'Pending',
                          stats.pendingTasks.toString(),
                          Colors.orange,
                          Icons.schedule_rounded,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          'In Progress',
                          stats.inProgressTasks.toString(),
                          Colors.blue,
                          Icons.sync_rounded,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          'Done',
                          stats.doneTasks.toString(),
                          Colors.green,
                          Icons.check_circle_outline_rounded,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Search & Filter
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          context.read<TaskProvider>().setSearchQuery(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Consumer<TaskProvider>(
                        builder: (context, provider, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<TaskStatus?>(
                                value: provider.statusFilter,
                                hint: const Text('All Status'),
                                icon: const Icon(Icons.filter_list_rounded),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Status'),
                                  ),
                                  ...TaskStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status.displayName),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  context.read<TaskProvider>().setStatusFilter(value);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Task List
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadTasks(refresh: true),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.assignment_add, size: 48, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a new task to get started',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showTaskForm(),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create Task'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadTasks(refresh: true);
                    await provider.loadStats();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    itemCount: provider.tasks.length + (provider.hasMorePages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.tasks.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final task = provider.tasks[index];
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: TaskCard(
                              task: task,
                              onTap: () => _showTaskForm(task: task),
                              onDelete: () => _confirmDelete(task),
                              onStatusChange: (status) {
                                provider.updateTask(id: task.id, status: status);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
        elevation: 4,
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
