class SupervisorJobItem {
  const SupervisorJobItem({
    required this.jobId,
    required this.jobName,
    required this.checked,
    required this.checkedCount,
    required this.totalCount,
  });

  final int jobId;
  final String jobName;
  final bool checked;
  final int checkedCount;
  final int totalCount;

  factory SupervisorJobItem.fromJson(Map<String, dynamic> json) {
    return SupervisorJobItem(
      jobId: json['jobId'] as int,
      jobName: json['jobName'] as String,
      checked: json['checked'] as bool,
      checkedCount: json['checkedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}

class SupervisorBoard {
  const SupervisorBoard({
    required this.meals,
    required this.selectedMeal,
    required this.jobs,
  });

  final List<String> meals;
  final String selectedMeal;
  final List<SupervisorJobItem> jobs;

  factory SupervisorBoard.fromJson(Map<String, dynamic> json) {
    return SupervisorBoard(
      meals: (json['meals'] as List<dynamic>).map((e) => e as String).toList(),
      selectedMeal: json['selectedMeal'] as String,
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => SupervisorJobItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SupervisorJobTaskItem {
  const SupervisorJobTaskItem({
    required this.taskId,
    required this.phase,
    required this.description,
    required this.checked,
  });

  final int taskId;
  final String phase;
  final String description;
  final bool checked;

  factory SupervisorJobTaskItem.fromJson(Map<String, dynamic> json) {
    return SupervisorJobTaskItem(
      taskId: json['taskId'] as int,
      phase: json['phase'] as String,
      description: json['description'] as String,
      checked: json['checked'] as bool,
    );
  }
}

class SupervisorJobTaskBoard {
  const SupervisorJobTaskBoard({
    required this.meal,
    required this.jobId,
    required this.jobName,
    required this.tasks,
  });

  final String meal;
  final int jobId;
  final String jobName;
  final List<SupervisorJobTaskItem> tasks;

  factory SupervisorJobTaskBoard.fromJson(Map<String, dynamic> json) {
    return SupervisorJobTaskBoard(
      meal: json['meal'] as String,
      jobId: json['jobId'] as int,
      jobName: json['jobName'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => SupervisorJobTaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SecondaryJobItem {
  const SecondaryJobItem({required this.name, required this.checked});

  final String name;
  final bool checked;

  SecondaryJobItem copyWith({bool? checked}) {
    return SecondaryJobItem(name: name, checked: checked ?? this.checked);
  }
}
