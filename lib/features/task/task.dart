import 'package:hive/hive.dart';

part 'task.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime createdAt;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Override toString for easy debugging
  @override
  String toString() {
    return 'Task(title: $title, description: $description, isCompleted: $isCompleted, createdAt: $createdAt)';
  }
}