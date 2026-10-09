import 'package:roundveil/domain/session/session_configuration.dart';

enum RuntimePhase { configuration, paused, active, complete }

class RuntimeSnapshot {
  const RuntimeSnapshot({
    required this.phase,
    required this.configuration,
    required this.updatedAt,
  });

  final RuntimePhase phase;
  final SessionConfiguration configuration;
  final DateTime updatedAt;
}

abstract interface class RuntimeCommand {}

abstract interface class GameRuntime {
  Stream<RuntimeSnapshot> get snapshots;

  Future<void> dispatch(RuntimeCommand command);
}
