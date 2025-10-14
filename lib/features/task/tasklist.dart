// import 'package:flutter/material.dart';
// import 'package:zenifytrip_guide/features/task/TaskService.dart';

// import 'package:zenifytrip_guide/features/task/taskpage.dart';
// import 'task.dart';

// class TaskListPage extends StatefulWidget {
//   final TaskService? taskService;

//   const TaskListPage({Key? key, this.taskService}) : super(key: key);

//   @override
//   _TaskListPageState createState() => _TaskListPageState();
// }

// class _TaskListPageState extends State<TaskListPage> {
//   late TaskService taskService;
//   List<Task> tasks = [];
//   List<Task> filteredTasks = [];
//   bool isLoading = false;
//   String searchQuery = '';
//   TaskFilter currentFilter = TaskFilter.all;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     taskService = widget.taskService ?? TaskService();
//     _loadTasks();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadTasks() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await Future.delayed(const Duration(milliseconds: 300)); // Smooth loading effect
//       tasks = taskService.getAllTasks();
//       _applyFilter();
//     } catch (e) {
//       _showErrorSnackBar('Error loading tasks: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _applyFilter() {
//     List<Task> filtered = [];
    
//     switch (currentFilter) {
//       case TaskFilter.all:
//         filtered = tasks;
//         break;
//       case TaskFilter.completed:
//         filtered = tasks.where((task) => task.isCompleted).toList();
//         break;
//       case TaskFilter.pending:
//         filtered = tasks.where((task) => !task.isCompleted).toList();
//         break;
//     }

//     if (searchQuery.isNotEmpty) {
//       filtered = filtered
//           .where((task) => 
//               task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               task.description.toLowerCase().contains(searchQuery.toLowerCase()))
//           .toList();
//     }

//     setState(() {
//       filteredTasks = filtered;
//     });
//   }

//   Future<void> _navigateToAddTask() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddTaskPage(taskService: taskService),
//       ),
//     );

//     if (result == true) {
//       _loadTasks();
//     }
//   }

//   Future<void> _toggleTaskCompletion(int index) async {
//     try {
//       await taskService.toggleTaskCompletion(index);
//       _loadTasks();
      
//       final task = tasks[index];
//       _showSuccessSnackBar(
//         task.isCompleted 
//           ? 'Task "${task.title}" marked as completed!'
//           : 'Task "${task.title}" marked as pending!'
//       );
//     } catch (e) {
//       _showErrorSnackBar('Error updating task: $e');
//     }
//   }

//   Future<void> _deleteTask(int index) async {
//     final task = tasks[index];
    
//     final confirmed = await _showDeleteConfirmation(task.title);
//     if (confirmed) {
//       try {
//         await taskService.deleteTask(index);
//         _loadTasks();
//         _showSuccessSnackBar('Task "${task.title}" deleted successfully!');
//       } catch (e) {
//         _showErrorSnackBar('Error deleting task: $e');
//       }
//     }
//   }

//   Future<bool> _showDeleteConfirmation(String taskTitle) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Task'),
//         content: Text('Are you sure you want to delete "$taskTitle"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }

//   Future<void> _clearAllTasks() async {
//     if (tasks.isEmpty) return;
    
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear All Tasks'),
//         content: Text('Are you sure you want to delete all ${tasks.length} tasks?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Clear All'),
//           ),
//         ],
//       ),
//     ) ?? false;

//     if (confirmed) {
//       try {
//         await taskService.clearAllTasks();
//         _loadTasks();
//         _showSuccessSnackBar('All tasks cleared successfully!');
//       } catch (e) {
//         _showErrorSnackBar('Error clearing tasks: $e');
//       }
//     }
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _onSearchChanged(String value) {
//     setState(() {
//       searchQuery = value;
//     });
//     _applyFilter();
//   }

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: TextField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: 'Search tasks...',
//           prefixIcon: const Icon(Icons.search),
//           suffixIcon: searchQuery.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () {
//                     _searchController.clear();
//                     _onSearchChanged('');
//                   },
//                 )
//               : null,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//           ),
//         ),
//         onChanged: _onSearchChanged,
//       ),
//     );
//   }

//   Widget _buildFilterChips() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Row(
//         children: TaskFilter.values.map((filter) {
//           return Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: FilterChip(
//               label: Text(_getFilterLabel(filter)),
//               selected: currentFilter == filter,
//               onSelected: (selected) {
//                 setState(() {
//                   currentFilter = filter;
//                 });
//                 _applyFilter();
//               },
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   String _getFilterLabel(TaskFilter filter) {
//     switch (filter) {
//       case TaskFilter.all:
//         return 'All (${tasks.length})';
//       case TaskFilter.completed:
//         return 'Completed (${tasks.where((t) => t.isCompleted).length})';
//       case TaskFilter.pending:
//         return 'Pending (${tasks.where((t) => !t.isCompleted).length})';
//     }
//   }

//   Widget _buildTaskItem(Task task, int index) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       elevation: 2,
//       child: ListTile(
//         leading: Checkbox(
//           value: task.isCompleted,
//           onChanged: (_) => _toggleTaskCompletion(index),
//         ),
//         title: Text(
//           task.title,
//           style: TextStyle(
//             decoration: task.isCompleted ? TextDecoration.lineThrough : null,
//             color: task.isCompleted ? Colors.grey : null,
//           ),
//         ),
//         subtitle: task.description.isNotEmpty
//             ? Text(
//                 task.description,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: task.isCompleted ? Colors.grey : null,
//                 ),
//               )
//             : null,
//         trailing: PopupMenuButton(
//           itemBuilder: (context) => [
//             PopupMenuItem(
//               value: 'toggle',
//               child: Row(
//                 children: [
//                   Icon(task.isCompleted ? Icons.undo : Icons.check),
//                   const SizedBox(width: 8),
//                   Text(task.isCompleted ? 'Mark Pending' : 'Mark Complete'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'delete',
//               child: Row(
//                 children: [
//                   Icon(Icons.delete, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Delete', style: TextStyle(color: Colors.red)),
//                 ],
//               ),
//             ),
//           ],
//           onSelected: (value) {
//             if (value == 'toggle') {
//               _toggleTaskCompletion(index);
//             } else if (value == 'delete') {
//               _deleteTask(index);
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     String message;
//     String submessage;
    
//     if (tasks.isEmpty) {
//       message = 'No tasks yet!';
//       submessage = 'Tap the + button to add your first task';
//     } else if (searchQuery.isNotEmpty) {
//       message = 'No tasks found';
//       submessage = 'Try adjusting your search or filter';
//     } else {
//       message = 'No ${_getFilterLabel(currentFilter).toLowerCase()}';
//       submessage = 'Try changing your filter';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.task_alt,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             submessage,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Tasks'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         actions: [
//           if (tasks.isNotEmpty)
//             PopupMenuButton(
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'clear_all',
//                   child: Row(
//                     children: [
//                       Icon(Icons.clear_all, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text('Clear All', style: TextStyle(color: Colors.red)),
//                     ],
//                   ),
//                 ),
//               ],
//               onSelected: (value) {
//                 if (value == 'clear_all') {
//                   _clearAllTasks();
//                 }
//               },
//             ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadTasks,
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   _buildSearchBar(),
//                   _buildFilterChips(),
//                   const SizedBox(height: 8),
//                   Expanded(
//                     child: filteredTasks.isEmpty
//                         ? _buildEmptyState()
//                         : ListView.builder(
//                             itemCount: filteredTasks.length,
//                             itemBuilder: (context, index) {
//                               final task = filteredTasks[index];
//                               final originalIndex = tasks.indexOf(task);
//                               return _buildTaskItem(task, originalIndex);
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToAddTask,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// enum TaskFilter {
//   all,
//   completed,
//   pending,
// }