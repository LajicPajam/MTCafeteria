import 'package:flutter/foundation.dart';

import '../models/landing_item.dart';
import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';
import '../services/api_client.dart';

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  UserSession? user;
  String? _token;

  bool isLoading = false;
  String? error;

  List<LandingItem> landingItems = const [];
  List<Training> trainings = const [];
  Training? todaysTraining;
  String? trainingDate;

  TaskBoard? taskBoard;
  SupervisorBoard? supervisorBoard;
  SupervisorJobTaskBoard? supervisorJobTaskBoard;
  int? supervisorSelectedJobId;
  TrainerBoard? trainerBoard;
  String supervisorPanelMode = 'Jobs';
  List<SecondaryJobItem> supervisorSecondaries = const [
    SecondaryJobItem(name: 'Trashes', checked: false),
    SecondaryJobItem(name: 'Spot Mop', checked: false),
    SecondaryJobItem(name: 'Wipe Tables', checked: false),
    SecondaryJobItem(name: 'Straighten Chairs', checked: false),
    SecondaryJobItem(name: 'Collect Red Buckets', checked: false),
  ];

  bool get isAuthenticated => user != null && _token != null;
  bool get canAccessSupervisorBoard =>
      user?.role == 'Supervisor' || user?.role == 'Student Manager';
  bool get canAccessTrainerBoard => user?.canAccessTrainerBoard ?? false;

  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _apiClient.login(email: email, password: password);
      _token = result.token;
      user = result.user;
      await Future.wait([
        refreshLandingItems(),
        refreshTrainingsIfAllowed(),
        refreshTaskBoard(),
        if (canAccessTrainerBoard) refreshTrainerBoard(),
        if (canAccessSupervisorBoard) refreshSupervisorBoard(),
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLandingItems() async {
    if (!isAuthenticated) return;
    final data = await _apiClient.getLandingItems(_token!);
    landingItems = data;
    notifyListeners();
  }

  Future<void> refreshTrainingsIfAllowed() async {
    if (!isAuthenticated || !(user?.canViewTrainings ?? false)) {
      trainings = const [];
      todaysTraining = null;
      trainingDate = null;
      notifyListeners();
      return;
    }

    final data = await _apiClient.getTrainings(_token!);
    trainings = data.trainings;
    todaysTraining = data.todaysTraining;
    trainingDate = data.today;
    notifyListeners();
  }

  Future<void> refreshTaskBoard({
    String? meal,
    int? jobId,
    String? preferredJobName,
  }) async {
    if (!isAuthenticated) return;
    final board = await _apiClient.getTaskBoard(
      _token!,
      meal: meal,
      jobId: jobId,
      preferredJobName: preferredJobName,
    );
    taskBoard = board;
    notifyListeners();
  }

  Future<void> selectMealKeepJob(String meal) async {
    if (!isAuthenticated) return;

    final currentBoard = taskBoard;
    String? currentJobName;
    if (currentBoard != null) {
      for (final job in currentBoard.jobs) {
        if (job.id == currentBoard.selectedJobId) {
          currentJobName = job.name;
          break;
        }
      }
    }

    await refreshTaskBoard(meal: meal, preferredJobName: currentJobName);
  }

  Future<void> setTaskCompletion({
    required int taskId,
    required bool completed,
  }) async {
    if (!isAuthenticated) return;
    await _apiClient.setTaskCompletion(
      _token!,
      taskId: taskId,
      completed: completed,
    );
    await refreshTaskBoard(
      meal: taskBoard?.selectedMeal,
      jobId: taskBoard?.selectedJobId,
    );
  }

  Future<void> refreshTrainerBoard({String? meal, List<int>? jobIds}) async {
    if (!isAuthenticated || !canAccessTrainerBoard) return;
    final board = await _apiClient.getTrainerBoard(
      _token!,
      meal: meal,
      jobIds: jobIds,
    );
    trainerBoard = board;
    notifyListeners();
  }

  Future<void> setTrainerTraineeTaskCompletion({
    required int traineeUserId,
    required int taskId,
    required bool completed,
  }) async {
    if (!isAuthenticated || !canAccessTrainerBoard || trainerBoard == null) {
      return;
    }
    await _apiClient.setTrainerTraineeTaskCompletion(
      _token!,
      traineeUserId: traineeUserId,
      taskId: taskId,
      completed: completed,
    );
    await refreshTrainerBoard(
      meal: trainerBoard!.selectedMeal,
      jobIds: trainerBoard!.selectedJobIds,
    );
  }

  Future<void> refreshSupervisorBoard({String? meal}) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    final board = await _apiClient.getSupervisorBoard(_token!, meal: meal);
    supervisorBoard = board;
    if (meal != null &&
        supervisorJobTaskBoard != null &&
        supervisorJobTaskBoard!.meal != board.selectedMeal) {
      supervisorJobTaskBoard = null;
      supervisorSelectedJobId = null;
    }
    notifyListeners();
  }

  Future<void> setSupervisorJobCheck({
    required int jobId,
    required bool checked,
  }) async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null) {
      return;
    }
    await _apiClient.setSupervisorJobCheck(
      _token!,
      meal: supervisorBoard!.selectedMeal,
      jobId: jobId,
      checked: checked,
    );
    await refreshSupervisorBoard(meal: supervisorBoard!.selectedMeal);
  }

  Future<void> resetSupervisorChecks() async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null) {
      return;
    }
    await _apiClient.resetSupervisorBoard(
      _token!,
      meal: supervisorBoard!.selectedMeal,
    );
    supervisorJobTaskBoard = null;
    supervisorSelectedJobId = null;
    await refreshSupervisorBoard(meal: supervisorBoard!.selectedMeal);
  }

  Future<void> openSupervisorJobTasks(int jobId) async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null) {
      return;
    }
    final board = await _apiClient.getSupervisorJobTasks(
      _token!,
      meal: supervisorBoard!.selectedMeal,
      jobId: jobId,
    );
    supervisorSelectedJobId = jobId;
    supervisorJobTaskBoard = board;
    supervisorPanelMode = 'Jobs';
    notifyListeners();
  }

  void closeSupervisorJobTasks() {
    supervisorSelectedJobId = null;
    supervisorJobTaskBoard = null;
    notifyListeners();
  }

  void setSupervisorPanelMode(String mode) {
    supervisorPanelMode = mode;
    notifyListeners();
  }

  void toggleSecondaryJob(int index, bool checked) {
    supervisorSecondaries = [
      for (var i = 0; i < supervisorSecondaries.length; i += 1)
        i == index
            ? supervisorSecondaries[i].copyWith(checked: checked)
            : supervisorSecondaries[i],
    ];
    notifyListeners();
  }

  void resetSecondaryJobs() {
    supervisorSecondaries = [
      for (final item in supervisorSecondaries) item.copyWith(checked: false),
    ];
    notifyListeners();
  }

  Future<void> setSupervisorTaskCheck({
    required int taskId,
    required bool checked,
  }) async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null ||
        supervisorSelectedJobId == null) {
      return;
    }

    await _apiClient.setSupervisorTaskCheck(
      _token!,
      meal: supervisorBoard!.selectedMeal,
      jobId: supervisorSelectedJobId!,
      taskId: taskId,
      checked: checked,
    );

    await openSupervisorJobTasks(supervisorSelectedJobId!);
    await refreshSupervisorBoard(meal: supervisorBoard!.selectedMeal);
  }

  Future<void> createLandingItem(Map<String, dynamic> payload) async {
    if (!isAuthenticated) return;
    await _apiClient.createLandingItem(_token!, payload);
    await refreshLandingItems();
  }

  Future<void> updateLandingItem(int id, Map<String, dynamic> payload) async {
    if (!isAuthenticated) return;
    await _apiClient.updateLandingItem(_token!, id, payload);
    await refreshLandingItems();
  }

  Future<void> deleteLandingItem(int id) async {
    if (!isAuthenticated) return;
    await _apiClient.deleteLandingItem(_token!, id);
    await refreshLandingItems();
  }

  void logout() {
    user = null;
    _token = null;
    error = null;
    landingItems = const [];
    trainings = const [];
    todaysTraining = null;
    trainingDate = null;
    taskBoard = null;
    supervisorBoard = null;
    supervisorJobTaskBoard = null;
    supervisorSelectedJobId = null;
    supervisorPanelMode = 'Jobs';
    supervisorSecondaries = const [
      SecondaryJobItem(name: 'Trashes', checked: false),
      SecondaryJobItem(name: 'Spot Mop', checked: false),
      SecondaryJobItem(name: 'Wipe Tables', checked: false),
      SecondaryJobItem(name: 'Straighten Chairs', checked: false),
      SecondaryJobItem(name: 'Collect Red Buckets', checked: false),
    ];
    trainerBoard = null;
    notifyListeners();
  }
}
