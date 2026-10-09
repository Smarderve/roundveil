import 'package:roundveil/domain/session/session_configuration.dart';

abstract interface class GameModule<State, Action, Outcome> {
  String get id;

  State createInitialState(SessionConfiguration configuration);

  ModuleTransition<State, Outcome> reduce(State state, Action action);
}

class ModuleTransition<State, Outcome> {
  const ModuleTransition({required this.state, this.outcome});

  final State state;
  final Outcome? outcome;
}
