import 'package:hive/hive.dart';
import 'task.dart';

class TaskService {
  static const String _boxName = 'tasks';
  Box<Task>? _taskBox;

  // Singleton pattern (optional but recommended for services)
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  // Initialize Hive and open the task box
  Future<void> init() async {
    if (_taskBox == null || !_taskBox!.isOpen) {
      _taskBox = await Hive.openBox<Task>(_boxName);
    }
  }

  // Ensure box is initialized before operations
  void _ensureInitialized() {
    if (_taskBox == null || !_taskBox!.isOpen) {
      throw StateError('TaskService not initialized. Call init() first.');
    }
  }

  // Get all tasks
  List<Task> getAllTasks() {
    _ensureInitialized();
    return _taskBox!.values.toList();
  }

  // Get task by index
  Task? getTask(int index) {
    _ensureInitialized();
    return _taskBox!.getAt(index);
  }

  // Add a new task
  Future<int> addTask(Task task) async {
    _ensureInitialized();
    return await _taskBox!.add(task);
  }

  // Update a task
  Future<void> updateTask(int index, Task task) async {
    _ensureInitialized();
    await _taskBox!.putAt(index, task);
  }

  // Delete a task
  Future<void> deleteTask(int index) async {
    _ensureInitialized();
    await _taskBox!.deleteAt(index);
  }

  // Delete task by key
  Future<void> deleteTaskByKey(dynamic key) async {
    _ensureInitialized();
    await _taskBox!.delete(key);
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(int index) async {
    _ensureInitialized();
    final task = _taskBox!.getAt(index);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save(); // Save changes since Task extends HiveObject
    }
  }

  // Get completed tasks
  List<Task> getCompletedTasks() {
    _ensureInitialized();
    return _taskBox!.values.where((task) => task.isCompleted).toList();
  }

  // Get pending tasks
  List<Task> getPendingTasks() {
    _ensureInitialized();
    return _taskBox!.values.where((task) => !task.isCompleted).toList();
  }

  // Search tasks by title
  List<Task> searchTasks(String query) {
    _ensureInitialized();
    return _taskBox!.values
        .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get tasks count
  int getTasksCount() {
    _ensureInitialized();
    return _taskBox!.length;
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    _ensureInitialized();
    await _taskBox!.clear();
  }

  // Close the box (call this when app is closing)
  Future<void> close() async {
    if (_taskBox != null && _taskBox!.isOpen) {
      await _taskBox!.close();
    }
  }

  // Check if service is initialized
  bool get isInitialized => _taskBox != null && _taskBox!.isOpen;
}