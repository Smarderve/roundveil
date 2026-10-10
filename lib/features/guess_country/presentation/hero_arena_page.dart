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
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 620;
      final issue = controller.configurationIssue;
      final ready = issue == null;
      return Column(
        key: const ValueKey('preparation'),
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 36,
                24,
                compact ? 18 : 36,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GameIdentity(compact: compact),
                      SizedBox(height: compact ? 28 : 38),
                      _PlayerLineup(
                        controller: controller,
                        state: state,
                        compact: compact,
                      ),
                      SizedBox(height: compact ? 26 : 34),
                      _MatchBrief(state: state),
                      const SizedBox(height: 14),
                      Align(
                        alignment: compact
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: ArenaButton(
                          label: 'MATCH RULES',
                          onPressed: () => _showMatchRules(context, controller),
                          secondary: true,
                        ),
                      ),
                      if (state.notice != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.notice!,
                          style: const TextStyle(color: Color(0xFFB13634)),
                        ),
                      ],
                      SizedBox(height: compact ? 28 : 40),
                      Center(
                        child: Column(
                          children: [
                            ArenaButton(
                              label: 'START MATCH',
                              onPressed: ready
                                  ? controller.prepareSession
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ready
                                  ? 'MATCH READY  •  ${state.players.length} ${state.players.length == 1 ? 'PLAYER' : 'PLAYERS'}  /  ${state.setup.roundCount} ${state.setup.roundCount == 1 ? 'ROUND' : 'ROUNDS'}'
                                  : _readinessPrompt(state, issue),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ready
                                    ? const Color(0xFF2879BA)
                                    : const Color(0xFF50647D),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  String _readinessPrompt(GuessCountryState state, String issue) {
    if (!state.setup.isComplete) return 'CHOOSE MATCH RULES TO CHECK READINESS';
    if (state.players.isEmpty) return 'ADD AT LEAST ONE PLAYER';
    return issue;
  }

  void _showMatchRules(
    BuildContext context,
    GuessCountryController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _MatchRulesDialog(controller: controller),
    );
  }
}

class _GameIdentity extends StatelessWidget {
  const _GameIdentity({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: -.16,
            child: const Icon(
              Icons.flag_rounded,
              color: Color(0xFFF4A62C),
              size: 25,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            compact ? 'FLAG CHALLENGE' : 'HERO ARENA  /  FLAG CHALLENGE',
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: Color(0xFF2879BA),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.25,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'GUESS THE COUNTRY',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF263449),
            fontSize: compact ? 36 : 62,
            height: .95,
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? -1.5 : -2.8,
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'THE WORLD IS YOUR ARENA',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF50647D),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.4,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        height: 3,
        width: compact ? 92 : 150,
        color: const Color(0xFFF4A62C),
      ),
    ],
  );
}

class _PlayerLineup extends StatelessWidget {
  const _PlayerLineup({
    required this.controller,
    required this.state,
    required this.compact,
  });
  final GuessCountryController controller;
  final GuessCountryState state;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'YOUR LINEUP',
              style: TextStyle(
                color: Color(0xFF263449),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Text(
            '${state.players.length} ${state.players.length == 1 ? 'PLAYER' : 'PLAYERS'}',
            style: const TextStyle(
              color: Color(0xFF50647D),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      const SizedBox(height: 13),
      Wrap(
        alignment: compact ? WrapAlignment.center : WrapAlignment.start,
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var index = 0; index < state.players.length; index++)
            _PlayerStand(
              index: index + 1,
              name: state.players[index].displayName,
              onRemove: () => controller.removePlayer(),
            ),
          _AddPlayerStand(onPressed: controller.addPlayer),
        ],
      ),
      if (state.players.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Add your first player to build the lineup.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF50647D), fontSize: 12),
          ),
        ),
    ],
  );
}

class _PlayerStand extends StatelessWidget {
  const _PlayerStand({
    required this.index,
    required this.name,
    required this.onRemove,
  });
  final int index;
  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    height: 128,
    child: ClipPath(
      clipper: _LobbyCut(),
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: const Color(0xFF263449))),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 7, color: const Color(0xFFF4A62C)),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              tooltip: 'Remove $name',
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: Color(0xFFDBE7F3), size: 19),
              visualDensity: VisualDensity.compact,
            ),
          ),
          Positioned(
            left: 19,
            top: 17,
            child: Text(
              'PLAYER ${index.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Color(0xFF8ABCE5),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 37,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Color(0xFFF4A62C),
                fontSize: 48,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 74,
            bottom: 18,
            right: 12,
            child: Text(
              name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _AddPlayerStand extends StatelessWidget {
  const _AddPlayerStand({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    height: 128,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF263449),
        side: const BorderSide(color: Color(0xFF2879BA), width: 2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: const Color(0x4479A6D2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 29, color: Color(0xFF2879BA)),
          SizedBox(height: 6),
          Text(
            'ADD PLAYER',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
        ],
      ),
    ),
  );
}

class _LobbyCut extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width - 18, 0)
    ..lineTo(size.width, 18)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _MatchBrief extends StatelessWidget {
  const _MatchBrief({required this.state});
  final GuessCountryState state;

  @override
  Widget build(BuildContext context) {
    final setup = state.setup;
    final entries = <String>[
      _rule('ROUNDS', setup.roundCount == null ? null : '${setup.roundCount}'),
      _rule('LEVEL', switch (setup.difficulty) {
        CountryDifficulty.easy => 'Easy',
        CountryDifficulty.medium => 'Medium',
        CountryDifficulty.hard => 'Hard',
        CountryDifficulty.expert => 'Expert',
        CountryDifficulty.mixed => 'Mixed',
        null => null,
      }),
      _rule('SCOPE', switch (setup.region) {
        CountryRegion.africa => 'Africa',
        CountryRegion.americas => 'Americas',
        CountryRegion.asia => 'Asia',
        CountryRegion.europe => 'Europe',
        CountryRegion.oceania => 'Oceania',
        CountryRegion.worldwide => 'Worldwide',
        null => null,
      }),
      _rule('ANSWER', switch (setup.answerMode) {
        CountryAnswerMode.multipleChoice => 'Multiple choice',
        CountryAnswerMode.typed => 'Typed answer',
        null => null,
      }),
      _rule(
        'TIMER',
        setup.challengeSeconds == null
            ? null
            : setup.challengeSeconds == 0
            ? 'Off'
            : '${setup.challengeSeconds}s',
      ),
      _rule(
        'HINTS',
        setup.hintsEnabled == null
            ? null
            : setup.hintsEnabled!
            ? 'On'
            : 'Off',
      ),
      _rule(
        'COUNTDOWN',
        setup.winCountdownSeconds == null
            ? null
            : '${setup.winCountdownSeconds}s',
      ),
      _rule(
        'SCORE',
        setup.scoringEnabled == null
            ? null
            : setup.scoringEnabled!
            ? 'On'
            : 'Off',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MATCH BRIEF',
          style: TextStyle(
            color: Color(0xFF263449),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 0,
          runSpacing: 6,
          children: [
            for (var index = 0; index < entries.length; index++) ...[
              if (index > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: Color(0xFFF4A62C),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              Text(
                entries[index],
                style: const TextStyle(
                  color: Color(0xFF50647D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _rule(String label, String? value) => '$label  ${value ?? 'NOT SET'}';
}

class _MatchRulesDialog extends ConsumerWidget {
  const _MatchRulesDialog({required this.controller});
  final GuessCountryController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guessCountryControllerProvider).state;
    final setup = state.setup;
    final compact = MediaQuery.sizeOf(context).width < 620;
    final issue = controller.configurationIssue;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 36,
        vertical: compact ? 12 : 28,
      ),
      backgroundColor: const Color(0xFFF3F7FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Color(0xFF2879BA), width: 2),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: MediaQuery.sizeOf(context).height * .94,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
              color: const Color(0xFF263449),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOST LOADOUT',
                          style: TextStyle(
                            color: Color(0xFF8ABCE5),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'MATCH RULES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close match rules',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 16 : 26,
                  10,
                  compact ? 16 : 26,
                  18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OptionGroup(
                      label: 'Rounds per player',
                      choices: const {'1': 1, '3': 3, '5': 5},
                      selected: setup.roundCount,
                      onSelected: (value) => controller.configure(
                        setup.copyWith(roundCount: value),
                      ),
                    ),
                    _OptionGroup(
                      label: 'Difficulty',
                      choices: const {
                        'Easy': CountryDifficulty.easy,
                        'Medium': CountryDifficulty.medium,
                        'Hard': CountryDifficulty.hard,
                        'Expert': CountryDifficulty.expert,
                        'Mixed': CountryDifficulty.mixed,
                      },
                      selected: setup.difficulty,
                      onSelected: (value) => controller.configure(
                        setup.copyWith(difficulty: value),
                      ),
                    ),
                    _OptionGroup(
                      label: 'Geographic scope',
                      choices: const {
                        'Africa': CountryRegion.africa,
                        'Americas': CountryRegion.americas,
                        'Asia': CountryRegion.asia,
                        'Europe': CountryRegion.europe,
                        'Oceania': CountryRegion.oceania,
                        'Worldwide': CountryRegion.worldwide,
                      },
                      selected: setup.region,
                      onSelected: (value) =>
                          controller.configure(setup.copyWith(region: value)),
                    ),
                    _OptionGroup(
                      label: 'Answer type',
                      choices: const {
                        'Multiple choice': CountryAnswerMode.multipleChoice,
                        'Type country': CountryAnswerMode.typed,
                      },
                      selected: setup.answerMode,
                      onSelected: (value) => controller.configure(
                        setup.copyWith(answerMode: value),
                      ),
                    ),
                    _OptionGroup(
                      label: 'Challenge timer',
                      choices: const {'Off': 0, '30 sec': 30, '45 sec': 45},
                      selected: setup.challengeSeconds,
                      onSelected: (value) => controller.configure(
                        setup.copyWith(challengeSeconds: value),
                      ),
                    ),
                    _OptionGroup(
                      label: 'Hints',
                      choices: const {'Off': false, 'On': true},
                      selected: setup.hintsEnabled,
                      onSelected: (value) => controller.configure(
                        setup.copyWith(hintsEnabled: value),
                      ),
                    ),
                    _OptionGroup(
                      label: 'Win Countdown',
                      choices: const {'3 sec': 3, '5 sec': 5, '8 sec': 8},
                      selected: setup.winCountdownSeconds,
                      onSelected: (value) => controller.configure(
                        setup.copyWith(winCountdownSeconds: value),
                      ),
                    ),
                    _OptionGroup(
                      label: 'Points & winner summary',
                      choices: const {'Off': false, 'On': true},
                      selected: setup.scoringEnabled,
                      onSelected: (value) => controller.configure(
                        setup.copyWith(scoringEnabled: value),
                      ),
                    ),
                    if (issue != null && setup.isComplete)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            issue,
                            style: const TextStyle(
                              color: Color(0xFF8C321F),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Align(
                alignment: Alignment.centerRight,
                child: ArenaButton(
                  label: 'DONE',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    padding: const EdgeInsets.only(top: 8),
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
          spacing: 4,
          runSpacing: 0,
          children: choices.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: ChoiceChip(
                    label: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFF263449),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: entry.value == selected,
                    showCheckmark: true,
                    checkmarkColor: const Color(0xFF263449),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    side: BorderSide(
                      color: entry.value == selected
                          ? const Color(0xFF2879BA)
                          : const Color(0xFFA3B5C6),
                      width: entry.value == selected ? 2 : 1,
                    ),
                    selectedColor: const Color(0xFFDBEBF9),
                    backgroundColor: const Color(0xFFF8FBFF),
                    onSelected: (_) => onSelected(entry.value),
                  ),
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
          _PlayerIdentity(name: state.activePlayer.displayName, large: true),
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      state.notice!.startsWith('Incorrect') ||
                          state.notice!.startsWith('Time expired')
                      ? const Color(0xFFFFE7E3)
                      : const Color(0xFFDDEAF5),
                  border: Border.all(
                    color:
                        state.notice!.startsWith('Incorrect') ||
                            state.notice!.startsWith('Time expired')
                        ? const Color(0xFFB13634)
                        : const Color(0xFF2879BA),
                  ),
                ),
                child: Text(
                  state.notice!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF263449),
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
          padding: EdgeInsets.all(compact ? 14 : 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PlayerIdentity(
                      name: state.activePlayer.displayName,
                      index: state.playerIndex + 1,
                    ),
                  ),
                  if (state.setup.scoringEnabled!)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        '${state.scores[state.activePlayer.displayName] ?? 0} PTS',
                        style: const TextStyle(
                          color: Color(0xFF2879BA),
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  if (state.setup.challengeSeconds! > 0)
                    _ChallengeTimer(
                      seconds: state.secondsRemaining,
                      total: state.setup.challengeSeconds!,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: LinearProgressIndicator(
                  value: (state.round - 1) / state.setup.roundCount!,
                  minHeight: 4,
                  backgroundColor: const Color(0x55A3B5C6),
                  color: const Color(0xFF2879BA),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'IDENTIFY THE FLAG',
                        style: TextStyle(
                          fontSize: compact ? 22 : 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: compact ? 360 : 620,
                          maxHeight: compact ? 230 : 360,
                        ),
                        child: AspectRatio(
                          aspectRatio: flag.aspectRatio,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFA3B5C6),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x29263449),
                                  blurRadius: 16,
                                  offset: Offset(0, 5),
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
                      const SizedBox(height: 12),
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
                        TextButton.icon(
                          onPressed: controller.revealHint,
                          icon: const Icon(Icons.lightbulb_outline, size: 18),
                          label: const Text('REVEAL HINT'),
                        ),
                      SizedBox(height: compact ? 4 : 10),
                      _AnswerArea(
                        controller: controller,
                        state: state,
                        textController: _answer,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'ROUND ${state.round.toString().padLeft(2, '0')} / ${state.setup.roundCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF50647D),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'HOST DEVICE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF50647D),
                      letterSpacing: 1,
                    ),
                  ),
                ],
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
      final options = controller.answerOptions;
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < options.length; index++)
              _AnswerOption(
                index: index + 1,
                label: options[index],
                onPressed: () => controller.submitAnswer(options[index]),
              ),
          ],
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
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
        ),
      ),
    );
  }
}

class _PlayerIdentity extends StatelessWidget {
  const _PlayerIdentity({
    required this.name,
    this.index = 1,
    this.large = false,
  });
  final String name;
  final int index;
  final bool large;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: large ? 62 : 40,
        height: large ? 62 : 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF2879BA),
          shape: BoxShape.circle,
        ),
        child: Text(
          index.toString().padLeft(2, '0'),
          style: TextStyle(
            color: Colors.white,
            fontSize: large ? 19 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      SizedBox(width: large ? 14 : 10),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!large)
              const Text(
                'ACTIVE PLAYER',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF2879BA),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            Text(
              name.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: large ? 42 : 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF263449),
                letterSpacing: -.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.label,
    required this.onPressed,
  });
  final int index;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF8FBFF),
    child: InkWell(
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFA3B5C6), width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 27,
              height: 27,
              alignment: Alignment.center,
              color: const Color(0xFFF4A62C),
              child: Text(
                index.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF263449),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ChallengeTimer extends StatelessWidget {
  const _ChallengeTimer({required this.seconds, required this.total});
  final int seconds;
  final int total;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$seconds seconds remaining',
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: seconds <= 10
            ? const Color(0xFFFFE7E3)
            : const Color(0xFF263449),
        border: Border.all(
          color: seconds <= 10
              ? const Color(0xFFB13634)
              : const Color(0xFF2879BA),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: seconds <= 10 ? const Color(0xFFB13634) : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                '$seconds',
                style: TextStyle(
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: seconds <= 10 ? const Color(0xFFB13634) : Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 74,
            child: LinearProgressIndicator(
              value: seconds / total,
              minHeight: 3,
              color: seconds <= 10
                  ? const Color(0xFFB13634)
                  : const Color(0xFFF4A62C),
              backgroundColor: const Color(0x557F93A8),
            ),
          ),
        ],
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
        TweenAnimationBuilder<double>(
          tween: Tween(begin: .72, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Text(
            '${state.secondsRemaining}',
            style: const TextStyle(
              fontSize: 180,
              height: .9,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF4A62C),
              shadows: [Shadow(color: Color(0xFF263449), offset: Offset(8, 8))],
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 240,
          child: LinearProgressIndicator(
            value: state.secondsRemaining / state.setup.winCountdownSeconds!,
            minHeight: 6,
            color: const Color(0xFF2879BA),
            backgroundColor: const Color(0x55A3B5C6),
          ),
        ),
        const SizedBox(height: 18),
        _PlayerIdentity(
          name: state.activePlayer.displayName,
          index: state.playerIndex + 1,
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
  Widget build(BuildContext context) {
    final scores = {
      for (final player in state.players)
        player.displayName: state.scores[player.displayName] ?? 0,
    };
    final highestScore = scores.values.fold<int>(
      0,
      (max, score) => score > max ? score : max,
    );
    final winners = scores.entries
        .where((entry) => entry.value == highestScore)
        .map((entry) => entry.key)
        .toList();
    final winnerText = highestScore == 0
        ? 'No points scored this match'
        : winners.length == 1
        ? '${winners.single.toUpperCase()} WINS'
        : 'IT’S A TIE';
    return Center(
      key: const ValueKey('complete'),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 44,
              color: Color(0xFFF4A62C),
            ),
            const Text(
              'SESSION COMPLETE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${state.players.length} ${state.players.length == 1 ? 'player' : 'players'} • ${state.setup.roundCount} ${state.setup.roundCount == 1 ? 'round' : 'rounds'}',
              style: const TextStyle(color: Color(0xFF50647D)),
            ),
            if (state.setup.scoringEnabled!) ...[
              const SizedBox(height: 16),
              Container(
                width: 420,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  border: Border.all(color: const Color(0xFF2879BA), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22263449), offset: Offset(4, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      winnerText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF2879BA),
                        fontSize: 20,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final player in state.players)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                player.displayName.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '${scores[player.displayName]} PTS',
                              style: const TextStyle(
                                color: Color(0xFF263449),
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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
}
