import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/landing_item.dart';
import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';

class ApiClient {
  ApiClient({String? baseUrl})
    : _baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://localhost:3001',
          );

  final String _baseUrl;

  Future<({String token, UserSession user})> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;

    return (
      token: data['token'] as String,
      user: UserSession(
        id: userJson['id'] as int,
        email: userJson['email'] as String,
        role: userJson['role'] as String,
        points: userJson['points'] as int? ?? 0,
      ),
    );
  }

  Future<List<LandingItem>> getLandingItems(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/content/landing-items'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch landing items');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => LandingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LandingItem> createLandingItem(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/content/landing-items'),
      headers: _jsonHeaders(token),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create landing item');
    }
    return LandingItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<LandingItem> updateLandingItem(
    String token,
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/content/landing-items/$id'),
      headers: _jsonHeaders(token),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update landing item');
    }
    return LandingItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteLandingItem(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/content/landing-items/$id'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete landing item');
    }
  }

  Future<({String today, List<Training> trainings, Training? todaysTraining})>
  getTrainings(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/trainings'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trainings');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final trainings = (data['trainings'] as List<dynamic>)
        .map((e) => Training.fromJson(e as Map<String, dynamic>))
        .toList();

    final todaysTrainingJson = data['todaysTraining'];
    return (
      today: data['today'] as String,
      trainings: trainings,
      todaysTraining: todaysTrainingJson == null
          ? null
          : Training.fromJson(todaysTrainingJson as Map<String, dynamic>),
    );
  }

  Future<TaskBoard> getTaskBoard(
    String token, {
    String? meal,
    int? jobId,
    String? preferredJobName,
  }) async {
    final params = <String, String>{};
    if (meal != null) params['meal'] = meal;
    if (jobId != null) params['jobId'] = '$jobId';
    if (preferredJobName != null && preferredJobName.isNotEmpty) {
      params['preferredJobName'] = preferredJobName;
    }

    final uri = Uri.parse(
      '$_baseUrl/api/task-board',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch task board');
    }

    return TaskBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setTaskCompletion(
    String token, {
    required int taskId,
    required bool completed,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/task-board/tasks/$taskId/completion'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'completed': completed}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update task completion');
    }
  }

  Future<SupervisorBoard> getSupervisorBoard(
    String token, {
    String? meal,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/supervisor-board',
    ).replace(queryParameters: meal == null ? null : {'meal': meal});

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch supervisor board');
    }

    return SupervisorBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setSupervisorJobCheck(
    String token, {
    required String meal,
    required int jobId,
    required bool checked,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/supervisor-board/jobs/$jobId/check'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal, 'checked': checked}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update supervisor checkoff');
    }
  }

  Future<void> resetSupervisorBoard(
    String token, {
    required String meal,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/supervisor-board/reset'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to reset supervisor board');
    }
  }

  Future<SupervisorJobTaskBoard> getSupervisorJobTasks(
    String token, {
    required String meal,
    required int jobId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/supervisor-board/jobs/$jobId/tasks',
    ).replace(queryParameters: {'meal': meal});

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch supervisor job tasks');
    }

    return SupervisorJobTaskBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setSupervisorTaskCheck(
    String token, {
    required String meal,
    required int jobId,
    required int taskId,
    required bool checked,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/supervisor-board/jobs/$jobId/tasks/$taskId/check',
      ),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal, 'checked': checked}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update supervisor task check');
    }
  }

  Future<TrainerBoard> getTrainerBoard(
    String token, {
    String? meal,
    List<int>? jobIds,
  }) async {
    final params = <String, String>{};
    if (meal != null) params['meal'] = meal;
    if (jobIds != null) {
      params['jobIds'] = jobIds.join(',');
    }

    final uri = Uri.parse(
      '$_baseUrl/api/trainer-board',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trainer board');
    }

    return TrainerBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setTrainerTraineeTaskCompletion(
    String token, {
    required int traineeUserId,
    required int taskId,
    required bool completed,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/trainer-board/trainees/$traineeUserId/tasks/$taskId/completion',
      ),
      headers: _jsonHeaders(token),
      body: jsonEncode({'completed': completed}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update trainee task completion');
    }
  }

  Map<String, String> _authHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, String> _jsonHeaders(String token) {
    return {..._authHeaders(token), 'Content-Type': 'application/json'};
  }
}
