class Task {
  final String title;
  final String description;
   bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ✅ Convert from JSON (for API or local storage)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  /// ✅ Convert to JSON (for saving or sending to API)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// ✅ Copy method for immutability (update fields safely)
  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// ✅ For easy debugging
  @override
  String toString() {
    return 'Task(title: $title, description: $description, isCompleted: $isCompleted, createdAt: $createdAt)';
  }
}
