// lib/models/reminder.dart

class Reminder {
  final int id;
  final String name;
  final String description;
  final int notificationCount;
  final Duration interval;
  final bool isConstant;

  Reminder({
    required this.id,
    required this.name,
    required this.description,
    required this.notificationCount,
    required this.interval,
    required this.isConstant,
  });
}
