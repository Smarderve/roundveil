import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roundveil/features/guess_country/application/guess_country_controller.dart';
import 'package:roundveil/features/guess_country/domain/country_flag.dart';
import 'package:roundveil/features/guess_country/presentation/hero_arena_components.dart';

final guessCountryControllerProvider =
    ChangeNotifierProvider<GuessCountryController>(
      (ref) => GuessCountryController(
        onCountdownComplete: () => SystemSound.play(SystemSoundType.alert),
      ),
    );

class HeroArenaPage extends ConsumerWidget {
  const HeroArenaPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(guessCountryControllerProvider);
    final state = controller.state;
    return Scaffold(
      body: ArenaBackdrop(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: _screen(context, controller, state),
        ),
      ),
    );
  }

  Widget _screen(
    BuildContext context,
    GuessCountryController controller,
    GuessCountryState state,
  ) => switch (state.screen) {
    ArenaScreen.opening => _Opening(controller: controller),
    ArenaScreen.preparation => _Preparation(
      controller: controller,
      state: state,
    ),
    ArenaScreen.playerReady => _PlayerReady(
      controller: controller,
      state: state,
    ),
    ArenaScreen.challenge => _Challenge(controller: controller, state: state),
    ArenaScreen.winCountdown => _Countdown(
      controller: controller,
      state: state,
    ),
    ArenaScreen.complete => _Complete(controller: controller, state: state),
  };
}

class _Opening extends StatelessWidget {
  const _Opening({required this.controller});
  final GuessCountryController controller;
  @override
  Widget build(BuildContext context) => Center(
    key: const ValueKey('opening'),
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ROUNDVEIL',
              style: TextStyle(
                fontSize: 66,
                height: .85,
                fontWeight: FontWeight.w900,
                letterSpacing: -3,
                color: Color(0xFF263449),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'HERO ARENA / UX CANDIDATE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFF2879BA),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Guess the Country',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF263449),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'A host-configured shared-screen challenge. This layout is a review candidate, not an approved final UX.',
              style: TextStyle(fontSize: 17, color: Color(0xFF50647D)),
            ),
            const SizedBox(height: 34),
            ArenaButton(label: 'PLAY', onPressed: controller.openPreparation),
          ],
        ),
      ),
    ),
  );
}

class _Preparation extends StatelessWidget {
  const _Preparation({required this.controller, required this.state});
  final GuessCountryController controller;
  final GuessCountryState state;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      key: const ValueKey('preparation'),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ArenaHeader(
                kicker: 'Host configuration',
                title: 'Build this match',
              ),
              const SizedBox(height: 10),
              const Text(
                'Every highlighted choice is a host decision. The included prototype pack limits available regions and difficulties.',
                style: TextStyle(color: Color(0xFF50647D)),
              ),
              const SizedBox(height: 24),
              const Text(
                'GAME  /  GUESS THE COUNTRY (FLAGS)',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFF2879BA),
                ),
              ),
              const SizedBox(height: 18),
              _PlayerRow(controller: controller, state: state),
              const SizedBox(height: 22),
              _OptionGroup(
                label: 'Rounds',
                choices: const {'3': 3, '5': 5},
                selected: state.setup.roundCount,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(roundCount: value),
                ),
              ),
              _OptionGroup(
                label: 'Difficulty',
                choices: {
                  for (final difficulty in controller.availableDifficulties)
                    switch (difficulty) {
                      CountryDifficulty.easy => 'Easy',
                      CountryDifficulty.medium => 'Medium',
                      CountryDifficulty.hard => 'Hard',
                      CountryDifficulty.expert => 'Expert',
                    }: difficulty,
                },
                selected: state.setup.difficulty,
                onSelected: (value) {
                  final currentRegion = state.setup.region;
                  final retainsRegion =
                      currentRegion != null &&
                      controller
                          .availableRegions(value)
                          .contains(currentRegion);
                  controller.configure(
                    state.setup.copyWith(
                      difficulty: value,
                      clearRegion: !retainsRegion,
                    ),
                  );
                },
              ),
              _OptionGroup(
                label: 'Geographical scope',
                choices: {
                  for (final region in controller.availableRegions(
                    state.setup.difficulty,
                  ))
                    switch (region) {
                      CountryRegion.africa => 'Africa',
                      CountryRegion.americas => 'Americas',
                      CountryRegion.asia => 'Asia',
                      CountryRegion.europe => 'Europe',
                    }: region,
                },
                selected: state.setup.region,
                onSelected: (value) =>
                    controller.configure(state.setup.copyWith(region: value)),
              ),
              _OptionGroup(
                label: 'Answer mode',
                choices: const {
                  'Multiple choice': CountryAnswerMode.multipleChoice,
                  'Typed answer': CountryAnswerMode.typed,
                },
                selected: state.setup.answerMode,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(answerMode: value),
                ),
              ),
              _OptionGroup(
                label: 'Challenge timer',
                choices: const {'Off': 0, '30 sec': 30, '45 sec': 45},
                selected: state.setup.challengeSeconds,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(challengeSeconds: value),
                ),
              ),
              _OptionGroup(
                label: 'Hints',
                choices: const {'Off': false, 'On': true},
                selected: state.setup.hintsEnabled,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(hintsEnabled: value),
                ),
              ),
              _OptionGroup(
                label: 'Win Countdown',
                choices: const {'3 sec': 3, '5 sec': 5, '8 sec': 8},
                selected: state.setup.winCountdownSeconds,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(winCountdownSeconds: value),
                ),
              ),
              _OptionGroup(
                label: 'Scoring',
                choices: const {'Off': false, 'On': true},
                selected: state.setup.scoringEnabled,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(scoringEnabled: value),
                ),
              ),
              if (state.notice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    state.notice!,
                    style: const TextStyle(
                      color: Color(0xFFB13634),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              ArenaButton(
                label: 'PREPARE MATCH',
                onPressed: state.isReady ? controller.prepareSession : null,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.controller, required this.state});
  final GuessCountryController controller;
  final GuessCountryState state;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'PLAYERS',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...state.players.map(
            (player) => ArenaChoice(
              label: player.displayName,
              selected: false,
              onPressed: () {},
            ),
          ),
          ArenaChoice(
            label: '+ PLAYER',
            selected: false,
            onPressed: controller.addPlayer,
          ),
          if (state.players.length > 1)
            ArenaChoice(
              label: '− LAST',
              selected: false,
              onPressed: controller.removePlayer,
            ),
        ],
      ),
    ],
  );
}

class _OptionGroup<T> extends StatelessWidget {
  const _OptionGroup({
    required this.label,
    required this.choices,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final Map<String, T> choices;
  final T? selected;
  final ValueChanged<T> onSelected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: choices.entries
              .map(
                (entry) => ArenaChoice(
                  label: entry.key,
                  selected: entry.value == selected,
                  onPressed: () => onSelected(entry.value),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

class _PlayerReady extends StatelessWidget {
  const _PlayerReady({required this.controller, required this.state});
  final GuessCountryController controller;
  final GuessCountryState state;
  @override
  Widget build(BuildContext context) => Center(
    key: const ValueKey('player-ready'),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ROUND ${state.round} / ${state.setup.roundCount}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2879BA),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'PLAYER READY',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            state.activePlayer.displayName.toUpperCase(),
            style: const TextStyle(
              fontSize: 56,
              height: 1,
              fontWeight: FontWeight.w900,
              color: Color(0xFF263449),
            ),
          ),
          if (state.setup.scoringEnabled!)
            Text(
              '${state.scores[state.activePlayer.displayName] ?? 0} POINTS',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2879BA),
                letterSpacing: 1.4,
              ),
            ),
          if (state.notice != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                state.notice!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF50647D)),
              ),
            ),
          const SizedBox(height: 32),
          ArenaButton(
            label: 'START CHALLENGE',
            onPressed: controller.startTurn,
          ),
        ],
      ),
    ),
  );
}

class _Challenge extends StatefulWidget {
  const _Challenge({required this.controller, required this.state});
  final GuessCountryController controller;
  final GuessCountryState state;
  @override
  State<_Challenge> createState() => _ChallengeState();
}

class _ChallengeState extends State<_Challenge> {
  final _answer = TextEditingController();
  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;
    final flag = controller.activeFlag;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        return Padding(
          key: const ValueKey('challenge'),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${state.activePlayer.displayName.toUpperCase()}  •  ROUND ${state.round}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (state.setup.challengeSeconds! > 0)
                    _Clock(seconds: state.secondsRemaining),
                ],
              ),
              const Spacer(),
              Text(
                'NAME THE COUNTRY',
                style: TextStyle(
                  fontSize: compact ? 22 : 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: compact ? 360 : 560,
                  maxHeight: compact ? 240 : 330,
                ),
                child: AspectRatio(
                  aspectRatio: flag.aspectRatio,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33263449),
                          blurRadius: 22,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      flag.assetPath,
                      fit: BoxFit.contain,
                      semanticsLabel: 'National flag challenge',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (state.hintVisible)
                Text(
                  'HINT • ${flag.hint}',
                  style: const TextStyle(
                    color: Color(0xFF2879BA),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              if (state.setup.hintsEnabled! && !state.hintVisible)
                TextButton(
                  onPressed: controller.revealHint,
                  child: const Text('REVEAL HOST-CONFIGURED HINT'),
                ),
              SizedBox(height: compact ? 8 : 16),
              _AnswerArea(
                controller: controller,
                state: state,
                textController: _answer,
              ),
              const Spacer(),
              const Text(
                'HOST CONTROLS REMAIN ON THIS DEVICE',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF50647D),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnswerArea extends StatelessWidget {
  const _AnswerArea({
    required this.controller,
    required this.state,
    required this.textController,
  });
  final GuessCountryController controller;
  final GuessCountryState state;
  final TextEditingController textController;
  @override
  Widget build(BuildContext context) {
    if (state.setup.answerMode == CountryAnswerMode.multipleChoice) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: controller.answerOptions
            .map(
              (answer) => ArenaChoice(
                label: answer,
                selected: false,
                onPressed: () => controller.submitAnswer(answer),
              ),
            )
            .toList(),
      );
    }
    return SizedBox(
      width: 420,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              onSubmitted: controller.submitAnswer,
              decoration: const InputDecoration(
                labelText: 'Country name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ArenaButton(
            label: 'SUBMIT',
            onPressed: () => controller.submitAnswer(textController.text),
          ),
        ],
      ),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock({required this.seconds});
  final int seconds;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$seconds seconds remaining',
    child: Text(
      '$seconds',
      style: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: Color(0xFFF4A62C),
        shadows: [Shadow(color: Color(0xFF263449), offset: Offset(1, 1))],
      ),
    ),
  );
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.controller, required this.state});
  final GuessCountryController controller;
  final GuessCountryState state;
  @override
  Widget build(BuildContext context) => Center(
    key: const ValueKey('countdown'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'WIN COUNTDOWN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Color(0xFF2879BA),
          ),
        ),
        Text(
          '${state.secondsRemaining}',
          style: const TextStyle(
            fontSize: 180,
            height: .9,
            fontWeight: FontWeight.w900,
            color: Color(0xFFF4A62C),
            shadows: [Shadow(color: Color(0xFF263449), offset: Offset(8, 8))],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          state.activePlayer.displayName.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 28),
        ArenaButton(
          label: 'END COUNTDOWN',
          onPressed: controller.completeCountdown,
          secondary: true,
        ),
      ],
    ),
  );
}

class _Complete extends StatelessWidget {
  const _Complete({required this.controller, required this.state});
  final GuessCountryController controller;
  final GuessCountryState state;
  @override
  Widget build(BuildContext context) => Center(
    key: const ValueKey('complete'),
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'SESSION COMPLETE',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${state.players.length} players • ${state.setup.roundCount} rounds',
            style: const TextStyle(color: Color(0xFF50647D)),
          ),
          if (state.setup.scoringEnabled!) ...[
            const SizedBox(height: 14),
            ...state.players.map(
              (player) => Text(
                '${player.displayName.toUpperCase()}  ${state.scores[player.displayName] ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
          const SizedBox(height: 28),
          ArenaButton(
            label: 'PREPARE ANOTHER',
            onPressed: controller.openPreparation,
          ),
          const SizedBox(height: 14),
          ArenaButton(
            label: 'FINISH',
            onPressed: controller.finishSession,
            secondary: true,
          ),
        ],
      ),
    ),
  );
}
