import 'package:roundveil/domain/runtime/game_runtime.dart';

abstract interface class SessionRepository {
  Future<RuntimeSnapshot?> loadActiveSession();

  Future<void> save(RuntimeSnapshot snapshot);
}
