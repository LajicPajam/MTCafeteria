import 'package:flutter/material.dart';

import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.availableModes,
    required this.selectedMode,
    required this.onModeChanged,
    required this.trainings,
    required this.todaysTraining,
    required this.trainingDate,
    required this.taskBoard,
    required this.trainerBoard,
    required this.supervisorBoard,
    required this.supervisorJobTaskBoard,
    required this.supervisorSelectedJobId,
    required this.supervisorPanelMode,
    required this.supervisorSecondaries,
    required this.onSelectMeal,
    required this.onSelectJob,
    required this.onTaskToggle,
    required this.onSelectTrainerMeal,
    required this.onSelectTrainerJobs,
    required this.onTrainerTaskToggle,
    required this.onSelectSupervisorMeal,
    required this.onSupervisorOpenJob,
    required this.onSupervisorCloseJob,
    required this.onSupervisorTaskToggle,
    required this.onSupervisorPanelModeChanged,
    required this.onSupervisorSecondaryToggle,
    required this.onSupervisorResetSecondaries,
    required this.onResetSupervisorChecks,
  });

  final UserSession user;
  final List<String> availableModes;
  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final List<Training> trainings;
  final Training? todaysTraining;
  final String? trainingDate;
  final TaskBoard? taskBoard;
  final TrainerBoard? trainerBoard;
  final SupervisorBoard? supervisorBoard;
  final SupervisorJobTaskBoard? supervisorJobTaskBoard;
  final int? supervisorSelectedJobId;
  final String supervisorPanelMode;
  final List<SecondaryJobItem> supervisorSecondaries;

  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onSelectJob;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;
  final Future<void> Function(String meal) onSelectTrainerMeal;
  final Future<void> Function(List<int> jobIds) onSelectTrainerJobs;
  final Future<void> Function(int traineeUserId, int taskId, bool completed)
  onTrainerTaskToggle;

  final Future<void> Function(String meal) onSelectSupervisorMeal;
  final Future<void> Function(int jobId) onSupervisorOpenJob;
  final VoidCallback onSupervisorCloseJob;
  final Future<void> Function(int taskId, bool checked) onSupervisorTaskToggle;
  final ValueChanged<String> onSupervisorPanelModeChanged;
  final void Function(int index, bool checked) onSupervisorSecondaryToggle;
  final VoidCallback onSupervisorResetSecondaries;
  final Future<void> Function() onResetSupervisorChecks;

  @override
  Widget build(BuildContext context) {
    final isEmployeeMode = selectedMode == 'Employee';
    final isLeadTrainerMode = selectedMode == 'Lead Trainer';
    final isSupervisorMode = selectedMode == 'Supervisor';
    final isStudentManagerMode = selectedMode == 'Student Manager';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.role} Dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (availableModes.length > 1) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableModes
                  .map(
                    (mode) => ChoiceChip(
                      label: Text(mode),
                      selected: selectedMode == mode,
                      onSelected: (_) => onModeChanged(mode),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (isLeadTrainerMode)
            _LeadTrainerTaskSection(
              trainerBoard: trainerBoard,
              onSelectMeal: onSelectTrainerMeal,
              onSelectJobs: onSelectTrainerJobs,
              onTraineeTaskToggle: onTrainerTaskToggle,
            )
          else if (isEmployeeMode)
            _EmployeeTaskSection(
              taskBoard: taskBoard,
              onSelectMeal: onSelectMeal,
              onSelectJob: onSelectJob,
              onTaskToggle: onTaskToggle,
            )
          else if (isSupervisorMode)
            _SupervisorSection(
              supervisorBoard: supervisorBoard,
              jobTaskBoard: supervisorJobTaskBoard,
              selectedJobId: supervisorSelectedJobId,
              panelMode: supervisorPanelMode,
              secondaries: supervisorSecondaries,
              onSelectMeal: onSelectSupervisorMeal,
              onOpenJob: onSupervisorOpenJob,
              onBackToJobs: onSupervisorCloseJob,
              onToggleTask: onSupervisorTaskToggle,
              onPanelModeChanged: onSupervisorPanelModeChanged,
              onSecondaryToggle: onSupervisorSecondaryToggle,
              onResetSecondaries: onSupervisorResetSecondaries,
              onResetAll: onResetSupervisorChecks,
            )
          else if (isStudentManagerMode)
            const _SimpleCard(
              title: 'Student Manager Dashboard',
              body:
                  'Use Landing Page for reminders/events. Switch to Supervisor or Lead Trainer mode for shift operations.',
            ),
          if (isLeadTrainerMode) ...[
            const SizedBox(height: 18),
            _TrainingAccessCard(
              today: trainingDate,
              todaysTraining: todaysTraining,
              trainings: trainings,
            ),
          ],
          if (isStudentManagerMode) ...[
            const SizedBox(height: 18),
            const _SimpleCard(
              title: 'Student Manager Tools',
              body:
                  'Use the Landing Page tab to add reminders, events, and activities for all users.',
            ),
          ],
          const SizedBox(height: 18),
          _PointsRiskCard(points: user.points),
        ],
      ),
    );
  }
}

class _EmployeeTaskSection extends StatelessWidget {
  const _EmployeeTaskSection({
    required this.taskBoard,
    required this.onSelectMeal,
    required this.onSelectJob,
    required this.onTaskToggle,
  });

  final TaskBoard? taskBoard;
  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onSelectJob;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;

  @override
  Widget build(BuildContext context) {
    if (taskBoard == null) {
      return const Text('Loading task board...');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Shift Tasks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Meal:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: taskBoard!.selectedMeal,
                      items: taskBoard!.meals
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onSelectMeal(value);
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Job:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value:
                          taskBoard!.jobs.any(
                            (j) => j.id == taskBoard!.selectedJobId,
                          )
                          ? taskBoard!.selectedJobId
                          : (taskBoard!.jobs.isNotEmpty
                                ? taskBoard!.jobs.first.id
                                : null),
                      items: taskBoard!.jobs
                          .map(
                            (j) => DropdownMenuItem(
                              value: j.id,
                              child: Text(j.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onSelectJob(value);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PhaseChecklist(
              phase: 'Setup (Before Doors Open)',
              tasks: taskBoard!.tasks.where((t) => t.phase == 'Setup').toList(),
              onTaskToggle: onTaskToggle,
            ),
            _PhaseChecklist(
              phase: 'During Shift (Doors Open)',
              tasks: taskBoard!.tasks
                  .where((t) => t.phase == 'During Shift')
                  .toList(),
              onTaskToggle: onTaskToggle,
            ),
            _PhaseChecklist(
              phase: 'Cleanup (After Doors Close)',
              tasks: taskBoard!.tasks
                  .where((t) => t.phase == 'Cleanup')
                  .toList(),
              onTaskToggle: onTaskToggle,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadTrainerTaskSection extends StatelessWidget {
  const _LeadTrainerTaskSection({
    required this.trainerBoard,
    required this.onSelectMeal,
    required this.onSelectJobs,
    required this.onTraineeTaskToggle,
  });

  final TrainerBoard? trainerBoard;
  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(List<int> jobIds) onSelectJobs;
  final Future<void> Function(int traineeUserId, int taskId, bool completed)
  onTraineeTaskToggle;

  @override
  Widget build(BuildContext context) {
    if (trainerBoard == null) {
      return const Text('Loading trainer board...');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trainee Support Board',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Meal:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: trainerBoard!.selectedMeal,
                  items: trainerBoard!.meals
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onSelectMeal(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Select trainee jobs for this meal:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trainerBoard!.jobs
                  .map(
                    (job) => FilterChip(
                      label: Text(job.name),
                      selected: trainerBoard!.selectedJobIds.contains(job.id),
                      onSelected: (selected) {
                        final next = [...trainerBoard!.selectedJobIds];
                        if (selected) {
                          if (!next.contains(job.id)) next.add(job.id);
                        } else {
                          next.remove(job.id);
                        }
                        onSelectJobs(next);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            if (trainerBoard!.trainees.isEmpty)
              const Text('No trainees mapped to the selected jobs.')
            else
              ...trainerBoard!.trainees.map(
                (trainee) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trainee.traineeName} • ${trainee.jobName}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _TrainerPhaseChecklist(
                          phase: 'Setup (Before Doors Open)',
                          tasks: trainee.tasks
                              .where((t) => t.phase == 'Setup')
                              .toList(),
                          traineeUserId: trainee.traineeUserId,
                          onToggle: onTraineeTaskToggle,
                        ),
                        _TrainerPhaseChecklist(
                          phase: 'During Shift (Doors Open)',
                          tasks: trainee.tasks
                              .where((t) => t.phase == 'During Shift')
                              .toList(),
                          traineeUserId: trainee.traineeUserId,
                          onToggle: onTraineeTaskToggle,
                        ),
                        _TrainerPhaseChecklist(
                          phase: 'Cleanup (After Doors Close)',
                          tasks: trainee.tasks
                              .where((t) => t.phase == 'Cleanup')
                              .toList(),
                          traineeUserId: trainee.traineeUserId,
                          onToggle: onTraineeTaskToggle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrainerPhaseChecklist extends StatelessWidget {
  const _TrainerPhaseChecklist({
    required this.phase,
    required this.tasks,
    required this.traineeUserId,
    required this.onToggle,
  });

  final String phase;
  final List<TrainerTraineeTask> tasks;
  final int traineeUserId;
  final Future<void> Function(int traineeUserId, int taskId, bool completed)
  onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (tasks.isEmpty)
            const Text('No tasks loaded for this section.')
          else
            ...tasks.map(
              (task) => task.requiresCheckoff
                  ? CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: task.completed,
                      title: Text(task.description),
                      onChanged: (value) {
                        if (value != null) {
                          onToggle(traineeUserId, task.taskId, value);
                        }
                      },
                    )
                  : ListTile(
                      dense: true,
                      leading: const Icon(Icons.remove, size: 18),
                      title: Text(task.description),
                      subtitle: const Text(
                        'Continuous during-shift responsibility',
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _PhaseChecklist extends StatelessWidget {
  const _PhaseChecklist({
    required this.phase,
    required this.tasks,
    required this.onTaskToggle,
  });

  final String phase;
  final List<TaskChecklistItem> tasks;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (tasks.isEmpty)
            const Text('No tasks loaded for this section.')
          else
            ...tasks.map(
              (task) => task.requiresCheckoff
                  ? CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: task.completed,
                      title: Text(task.description),
                      onChanged: (value) {
                        if (value != null) {
                          onTaskToggle(task.taskId, value);
                        }
                      },
                    )
                  : ListTile(
                      dense: true,
                      leading: const Icon(Icons.remove, size: 18),
                      title: Text(task.description),
                      subtitle: const Text(
                        'Continuous during-shift responsibility',
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _SupervisorSection extends StatelessWidget {
  const _SupervisorSection({
    required this.supervisorBoard,
    required this.jobTaskBoard,
    required this.selectedJobId,
    required this.panelMode,
    required this.secondaries,
    required this.onSelectMeal,
    required this.onOpenJob,
    required this.onBackToJobs,
    required this.onToggleTask,
    required this.onPanelModeChanged,
    required this.onSecondaryToggle,
    required this.onResetSecondaries,
    required this.onResetAll,
  });

  final SupervisorBoard? supervisorBoard;
  final SupervisorJobTaskBoard? jobTaskBoard;
  final int? selectedJobId;
  final String panelMode;
  final List<SecondaryJobItem> secondaries;
  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onOpenJob;
  final VoidCallback onBackToJobs;
  final Future<void> Function(int taskId, bool checked) onToggleTask;
  final ValueChanged<String> onPanelModeChanged;
  final void Function(int index, bool checked) onSecondaryToggle;
  final VoidCallback onResetSecondaries;
  final Future<void> Function() onResetAll;

  @override
  Widget build(BuildContext context) {
    if (supervisorBoard == null) {
      return const Text('Loading supervisor board...');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Supervisor Checkoff',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (panelMode == 'Jobs')
                  OutlinedButton(
                    onPressed: onResetAll,
                    child: const Text('Reset All for Meal'),
                  )
                else
                  OutlinedButton(
                    onPressed: onResetSecondaries,
                    child: const Text('Reset Secondaries'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Jobs'),
                  selected: panelMode == 'Jobs',
                  onSelected: (_) => onPanelModeChanged('Jobs'),
                ),
                ChoiceChip(
                  label: const Text('Secondaries'),
                  selected: panelMode == 'Secondaries',
                  onSelected: (_) => onPanelModeChanged('Secondaries'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (panelMode == 'Jobs' && selectedJobId == null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Meal:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: supervisorBoard!.selectedMeal,
                    items: supervisorBoard!.meals
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onSelectMeal(value);
                      }
                    },
                  ),
                ],
              )
            else if (panelMode == 'Jobs')
              TextButton.icon(
                onPressed: onBackToJobs,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Jobs'),
              ),
            const SizedBox(height: 6),
            if (panelMode == 'Secondaries')
              ...secondaries.asMap().entries.map(
                (entry) => CheckboxListTile(
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: entry.value.checked,
                  title: Text(entry.value.name),
                  onChanged: (value) {
                    if (value != null) {
                      onSecondaryToggle(entry.key, value);
                    }
                  },
                ),
              )
            else if (selectedJobId == null)
              ...supervisorBoard!.jobs.map(
                (job) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.work_outline),
                  title: Text(job.jobName),
                  subtitle: Text(
                    '${job.checkedCount}/${job.totalCount} tasks checked',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onOpenJob(job.jobId),
                ),
              )
            else if (jobTaskBoard == null)
              const Text('Loading job tasks...')
            else ...[
              Text(
                '${jobTaskBoard!.jobName} • ${jobTaskBoard!.meal}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...jobTaskBoard!.tasks.map(
                (task) => CheckboxListTile(
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: task.checked,
                  title: Text(task.description),
                  onChanged: (value) {
                    if (value != null) {
                      onToggleTask(task.taskId, value);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PointsRiskCard extends StatelessWidget {
  const _PointsRiskCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    String status;
    Color color;

    if (points >= 20) {
      status = 'Critical: 20+ points means termination threshold.';
      color = Colors.red.shade700;
    } else if (points >= 15) {
      status = 'Warning: 15+ points means supervisor conversation threshold.';
      color = Colors.orange.shade700;
    } else {
      status = 'Below warning threshold.';
      color = Colors.green.shade700;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Points: $points',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              status,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingAccessCard extends StatelessWidget {
  const _TrainingAccessCard({
    required this.today,
    required this.todaysTraining,
    required this.trainings,
  });

  final String? today;
  final Training? todaysTraining;
  final List<Training> trainings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Two-Minute Trainings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _TrainingDetailPage(
                      today: today,
                      todaysTraining: todaysTraining,
                      trainings: trainings,
                    ),
                  ),
                );
              },
              child: const Text('View 2-minute Trainings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingDetailPage extends StatelessWidget {
  const _TrainingDetailPage({
    required this.today,
    required this.todaysTraining,
    required this.trainings,
  });

  final String? today;
  final Training? todaysTraining;
  final List<Training> trainings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2-Minute Training')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (today != null) Text('Today: $today'),
            const SizedBox(height: 12),
            if (todaysTraining != null) ...[
              Text(
                todaysTraining!.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(todaysTraining!.content),
            ] else ...[
              const Text('No training assigned for today.'),
              const SizedBox(height: 12),
              ...trainings.map(
                (training) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(training.title),
                  subtitle: Text(training.assignedDate),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
