// lib/models/questionnaire_data.dart
class QuestionnaireData {
  // RestrictionsScreen Daten
  final String visualImpairment;
  final Map<String, bool> assistiveTools;
  final Map<String, bool> safetyAspects;
  final String? medicationDetails;

  // PreferencesScreen Daten
  final String fitnessLevel;
  final Map<String, bool> goals;

  // Metadaten
  final DateTime completedAt;
  final String userId;

  QuestionnaireData({
    required this.visualImpairment,
    required this.assistiveTools,
    required this.safetyAspects,
    this.medicationDetails,
    required this.fitnessLevel,
    required this.goals,
    required this.userId,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  // Zu JSON konvertieren für Firebase
  Map<String, dynamic> toJson() {
    return {
      'visualImpairment': visualImpairment,
      'assistiveTools': assistiveTools,
      'safetyAspects': safetyAspects,
      'medicationDetails': medicationDetails ?? '',
      'fitnessLevel': fitnessLevel,
      'goals': goals,
      'completedAt': completedAt.toIso8601String(),
      'userId': userId,
    };
  }

  // Von JSON zu Objekt (für späteres Laden)
  factory QuestionnaireData.fromJson(Map<String, dynamic> json) {
    return QuestionnaireData(
      visualImpairment: json['visualImpairment'] ?? '',
      assistiveTools: Map<String, bool>.from(json['assistiveTools'] ?? {}),
      safetyAspects: Map<String, bool>.from(json['safetyAspects'] ?? {}),
      medicationDetails: json['medicationDetails'],
      fitnessLevel: json['fitnessLevel'] ?? '',
      goals: Map<String, bool>.from(json['goals'] ?? {}),
      userId: json['userId'] ?? '',
      completedAt: DateTime.parse(json['completedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}