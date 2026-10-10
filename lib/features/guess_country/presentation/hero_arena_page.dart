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
      final wide = constraints.maxWidth >= 780;
      final left = <Widget>[
        _SetupSection(
          number: '01',
          title: 'Players & rounds',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlayerRow(controller: controller, state: state),
              const SizedBox(height: 14),
              _OptionGroup(
                label: 'Rounds per player',
                choices: const {'1': 1, '3': 3, '5': 5},
                selected: state.setup.roundCount,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(roundCount: value),
                ),
              ),
            ],
          ),
        ),
        _SetupSection(
          number: '02',
          title: 'Flag challenge',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OptionGroup(
                label: 'Difficulty',
                choices: const {
                  'Easy': CountryDifficulty.easy,
                  'Medium': CountryDifficulty.medium,
                  'Hard': CountryDifficulty.hard,
                  'Expert': CountryDifficulty.expert,
                  'Mixed': CountryDifficulty.mixed,
                },
                selected: state.setup.difficulty,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(difficulty: value),
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
                selected: state.setup.region,
                onSelected: (value) =>
                    controller.configure(state.setup.copyWith(region: value)),
              ),
              _OptionGroup(
                label: 'Answer type',
                choices: const {
                  'Multiple choice': CountryAnswerMode.multipleChoice,
                  'Type country': CountryAnswerMode.typed,
                },
                selected: state.setup.answerMode,
                onSelected: (value) => controller.configure(
                  state.setup.copyWith(answerMode: value),
                ),
              ),
            ],
          ),
        ),
      ];
      final right = <Widget>[
        _SetupSection(
          number: '03',
          title: 'Pace & assists',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
        _SetupSection(
          number: '04',
          title: 'Scorekeeping',
          child: _OptionGroup(
            label: 'Points & winner summary',
            choices: const {'Off': false, 'On': true},
            selected: state.setup.scoringEnabled,
            onSelected: (value) => controller.configure(
              state.setup.copyWith(scoringEnabled: value),
            ),
          ),
        ),
      ];
      return Column(
        key: const ValueKey('preparation'),
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ArenaHeader(
                        kicker: 'HOST CONTROL',
                        title: 'Set the match',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose every rule before the first turn. No match settings are preselected.',
                        style: TextStyle(color: Color(0xFF50647D)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GUESS THE COUNTRY  /  OFFLINE FLAG REVIEW PACK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: Color(0xFF2879BA),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Column(children: left)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(children: right)),
                          ],
                        )
                      else ...[
                        ...left,
                        ...right,
                      ],
                      if (controller.configurationIssue != null)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E0),
                            border: Border.all(color: const Color(0xFFF4A62C)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF263449),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  controller.configurationIssue!,
                                  style: const TextStyle(
                                    color: Color(0xFF263449),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (state.notice != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            state.notice!,
                            style: const TextStyle(color: Color(0xFFB13634)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F7FC),
              border: Border(top: BorderSide(color: Color(0xFFA3B5C6))),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'HOST CONFIGURATION',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF50647D),
                        ),
                      ),
                    ),
                    ArenaButton(
                      label: 'PREPARE MATCH',
                      onPressed: controller.configurationIssue == null
                          ? controller.prepareSession
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _SetupSection extends StatelessWidget {
  const _SetupSection({
    required this.number,
    required this.title,
    required this.child,
  });
  final String number;
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
    decoration: BoxDecoration(
      color: const Color(0xCCF8FBFF),
      border: Border(
        left: BorderSide(color: const Color(0xFF2879BA), width: 3),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Color(0xFF2879BA),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                letterSpacing: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
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
      if (state.players.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            'No players added yet. Choose who will take turns.',
            style: TextStyle(color: Color(0xFF50647D), fontSize: 12),
          ),
        ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < state.players.length; index++)
            Chip(
              avatar: CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF2879BA),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              label: Text(state.players[index].displayName),
              side: const BorderSide(color: Color(0xFFA3B5C6)),
              backgroundColor: const Color(0xFFF8FBFF),
              visualDensity: VisualDensity.compact,
            ),
          ArenaChoice(
            label: state.players.isEmpty ? '+ ADD PLAYER' : '+ PLAYER',
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
