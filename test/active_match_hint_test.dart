import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/active_match/application/answer_letter_hint.dart';

void main() {
  test('hint popup can reopen without another credit charge', () async {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['quiz'],
      roundCount: 1,
      hintsEnabled: true,
    );
    final repository = InMemoryPlayerProfileRepository();
    await repository.ensureProfiles(configuration.players);
    final profiles = await repository.loadAll();
    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      random: Random(11),
      profileRepository: repository,
      profiles: {for (final profile in profiles) profile.id: profile},
    );
    match.beginChallenge();

    final answer = match.state.challenge.answer;
    final initialCredits = match.state.profiles.values.single.hintCredits;
    expect(await match.revealHint(), isTrue);
    expect(match.state.hintVisible, isTrue);
    expect(match.state.hintText, buildAnswerLetterHint(answer));
    expect(match.state.profiles.values.single.hintCredits, initialCredits - 1);

    match.dismissHint();
    expect(match.state.hintVisible, isFalse);
    expect(match.state.hintText, isNotEmpty);
    expect(await match.revealHint(), isTrue);
    expect(match.state.hintVisible, isTrue);
    expect(match.state.profiles.values.single.hintCredits, initialCredits - 1);
    expect((await repository.loadAll()).single.hintCredits, initialCredits - 1);
    match.dispose();
  });
}
