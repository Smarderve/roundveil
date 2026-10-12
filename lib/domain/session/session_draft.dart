import 'session_configuration.dart';

class SessionDraft {
  const SessionDraft({
    required this.id,
    required this.name,
    required this.configuration,
    required this.updatedAt,
    this.templateId,
  });

  final String id;
  final String name;
  final SessionConfiguration configuration;
  final DateTime updatedAt;
  final String? templateId;

  /// True for saved configurations that refer to a game no longer offered.
  /// The original serialized data is preserved until the host edits and saves.
  bool get needsEditing =>
      configuration.selectedModuleIds.any(
        (id) => !activeGameModuleIds.contains(id),
      );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'configuration': configuration.toJson(),
    'updatedAt': updatedAt.toIso8601String(),
    'templateId': templateId,
  };

  factory SessionDraft.fromJson(Map<String, Object?> json) => SessionDraft(
    id: json['id']! as String,
    name: json['name']! as String,
    configuration: SessionConfiguration.fromJson(
      json['configuration']! as Map<String, Object?>,
    ),
    updatedAt: DateTime.parse(json['updatedAt']! as String),
    templateId: json['templateId'] as String?,
  );
}
