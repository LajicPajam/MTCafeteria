import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'state/app_state.dart';

void main() {
  runApp(const MtcCafeteriaApp());
}

class MtcCafeteriaApp extends StatefulWidget {
  const MtcCafeteriaApp({super.key});

  @override
  State<MtcCafeteriaApp> createState() => _MtcCafeteriaAppState();
}

class _MtcCafeteriaAppState extends State<MtcCafeteriaApp> {
  final AppState _state = AppState();
  int _selectedIndex = 0;
  String _dashboardMode = 'Employee';

  List<String> _availableDashboardModesForRole(String role) {
    switch (role) {
      case 'Lead Trainer':
        return const ['Lead Trainer', 'Employee'];
      case 'Supervisor':
        return const ['Supervisor', 'Lead Trainer', 'Employee'];
      case 'Student Manager':
        return const [
          'Student Manager',
          'Supervisor',
          'Lead Trainer',
          'Employee',
        ];
      default:
        return const ['Employee'];
    }
  }

  String _defaultDashboardModeForRole(String role) {
    return _availableDashboardModesForRole(role).first;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final user = _state.user;
        final isLoggedIn = _state.isAuthenticated;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MTC Cafeteria Prototype',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F6B4F),
            ),
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('MTC Cafeteria'),
              actions: [
                TextButton(
                  onPressed: isLoggedIn
                      ? () => setState(() => _selectedIndex = 0)
                      : null,
                  child: const Text('Landing Page'),
                ),
                TextButton(
                  onPressed: isLoggedIn
                      ? () => setState(() => _selectedIndex = 1)
                      : null,
                  child: const Text('Dashboard'),
                ),
                const SizedBox(width: 12),
                if (isLoggedIn)
                  TextButton(
                    onPressed: () {
                      _state.logout();
                      setState(() {
                        _selectedIndex = 0;
                        _dashboardMode = 'Employee';
                      });
                    },
                    child: const Text('Logout'),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(child: Text('Login')),
                  ),
              ],
            ),
            body: !isLoggedIn
                ? LoginPage(
                    isLoading: _state.isLoading,
                    error: _state.error,
                    onLogin: (email, password) async {
                      await _state.login(email, password);
                      if (_state.isAuthenticated && mounted) {
                        setState(() {
                          _selectedIndex = 0;
                          _dashboardMode = _defaultDashboardModeForRole(
                            _state.user!.role,
                          );
                        });
                      }
                    },
                  )
                : _selectedIndex == 0
                ? LandingPage(
                    items: _state.landingItems,
                    canManage: user!.canManageLanding,
                    onCreate: (payload) => _state.createLandingItem(payload),
                    onUpdate: (id, payload) =>
                        _state.updateLandingItem(id, payload),
                    onDelete: (id) => _state.deleteLandingItem(id),
                  )
                : DashboardPage(
                    user: user!,
                    availableModes: _availableDashboardModesForRole(user.role),
                    selectedMode: _dashboardMode,
                    onModeChanged: (mode) =>
                        setState(() => _dashboardMode = mode),
                    trainings: _state.trainings,
                    todaysTraining: _state.todaysTraining,
                    trainingDate: _state.trainingDate,
                    taskBoard: _state.taskBoard,
                    trainerBoard: _state.trainerBoard,
                    supervisorBoard: _state.supervisorBoard,
                    supervisorJobTaskBoard: _state.supervisorJobTaskBoard,
                    supervisorSelectedJobId: _state.supervisorSelectedJobId,
                    supervisorPanelMode: _state.supervisorPanelMode,
                    supervisorSecondaries: _state.supervisorSecondaries,
                    onSelectMeal: (meal) => _state.selectMealKeepJob(meal),
                    onSelectJob: (jobId) => _state.refreshTaskBoard(
                      meal: _state.taskBoard?.selectedMeal,
                      jobId: jobId,
                    ),
                    onTaskToggle: (taskId, completed) =>
                        _state.setTaskCompletion(
                          taskId: taskId,
                          completed: completed,
                        ),
                    onSelectTrainerMeal: (meal) =>
                        _state.refreshTrainerBoard(meal: meal),
                    onSelectTrainerJobs: (jobIds) => _state.refreshTrainerBoard(
                      meal: _state.trainerBoard?.selectedMeal,
                      jobIds: jobIds,
                    ),
                    onTrainerTaskToggle: (traineeUserId, taskId, completed) =>
                        _state.setTrainerTraineeTaskCompletion(
                          traineeUserId: traineeUserId,
                          taskId: taskId,
                          completed: completed,
                        ),
                    onSelectSupervisorMeal: (meal) =>
                        _state.refreshSupervisorBoard(meal: meal),
                    onSupervisorOpenJob: (jobId) =>
                        _state.openSupervisorJobTasks(jobId),
                    onSupervisorCloseJob: () =>
                        _state.closeSupervisorJobTasks(),
                    onSupervisorTaskToggle: (taskId, checked) =>
                        _state.setSupervisorTaskCheck(
                          taskId: taskId,
                          checked: checked,
                        ),
                    onSupervisorPanelModeChanged: (mode) =>
                        _state.setSupervisorPanelMode(mode),
                    onSupervisorSecondaryToggle: (index, checked) =>
                        _state.toggleSecondaryJob(index, checked),
                    onSupervisorResetSecondaries: () =>
                        _state.resetSecondaryJobs(),
                    onResetSupervisorChecks: () =>
                        _state.resetSupervisorChecks(),
                  ),
            bottomNavigationBar: user == null
                ? null
                : Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text('Signed in as ${user.email} (${user.role})'),
                  ),
          ),
        );
      },
    );
  }
}
