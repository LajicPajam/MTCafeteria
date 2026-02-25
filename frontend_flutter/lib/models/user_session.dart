class UserSession {
  const UserSession({
    required this.id,
    required this.email,
    required this.role,
    required this.points,
  });

  final int id;
  final String email;
  final String role;
  final int points;

  bool get canManageLanding =>
      role == 'Student Manager' || role == 'Supervisor';
  bool get canViewTrainings =>
      role == 'Lead Trainer' ||
      role == 'Supervisor' ||
      role == 'Student Manager';
  bool get canAccessTrainerBoard =>
      role == 'Lead Trainer' ||
      role == 'Supervisor' ||
      role == 'Student Manager';
}
