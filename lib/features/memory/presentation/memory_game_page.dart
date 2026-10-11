import 'dart:async';

import 'package:flutter/material.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/memory/application/memory_game_controller.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({
    required this.players,
    required this.rounds,
    required this.onExit,
    this.seed = 1,
    super.key,
  });

  final List<PlayerConfiguration> players;
  final int rounds;
  final VoidCallback onExit;
  final int seed;

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  String? _timerSelection;
  int? _challengeSeconds;
  int? _winCountdownSeconds;
  bool? _hintsEnabled;
  bool? _scoringEnabled;
  MemoryGameController? _controller;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startMatch() {
    if (_timerSelection == null ||
        _winCountdownSeconds == null ||
        _hintsEnabled == null ||
        _scoringEnabled == null) {
      return;
    }
    final controller = MemoryGameController(
      players: widget.players,
      rounds: widget.rounds,
      challengeSeconds: _challengeSeconds,
      winCountdownSeconds: _winCountdownSeconds!,
      hintsEnabled: _hintsEnabled!,
      scoringEnabled: _scoringEnabled!,
      seed: widget.seed,
    )..start();
    setState(() => _controller = controller);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      controller.tick();
      if (controller.state.phase == MemoryGamePhase.complete) {
        _ticker?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return _buildSetup(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _buildGame(context, controller.state),
    );
  }

  Widget _buildSetup(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final ready =
        _timerSelection != null &&
        _winCountdownSeconds != null &&
        _hintsEnabled != null &&
        _scoringEnabled != null &&
        widget.players.isNotEmpty &&
        widget.rounds > 0;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const V5SceneArt(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xE9061429), Color(0xC8041021)],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: <Widget>[
              _topBar(context, 'MEMORY // MATCH PREPARATION'),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        constraints.maxHeight < 420 ||
                        constraints.maxWidth < 700;
                    final rulePickers = <Widget>[
                      _RulePicker<String>(
                        compact: compact,
                        title: 'TURN TIMER',
                        choices: <_RuleChoice<String>>[
                          _RuleChoice('UNTIMED', 'unlimited'),
                          const _RuleChoice('20 SEC', '20'),
                          const _RuleChoice('30 SEC', '30'),
                          const _RuleChoice('60 SEC', '60'),
                        ],
                        selected: _timerSelection,
                        keyFor: (value) => 'memory-timer-$value',
                        onChanged: (value) => setState(() {
                          _timerSelection = value;
                          _challengeSeconds = int.tryParse(value);
                        }),
                      ),
                      _RulePicker<int>(
                        compact: compact,
                        title: 'WIN COUNTDOWN',
                        choices: <_RuleChoice<int>>[
                          for (final seconds in <int>[3, 5, 10])
                            _RuleChoice('$seconds SEC', seconds),
                        ],
                        selected: _winCountdownSeconds,
                        keyFor: (value) => 'memory-countdown-$value',
                        onChanged: (value) =>
                            setState(() => _winCountdownSeconds = value),
                      ),
                      _RulePicker<bool>(
                        compact: compact,
                        title: 'HINTS',
                        choices: const <_RuleChoice<bool>>[
                          _RuleChoice('ON', true),
                          _RuleChoice('OFF', false),
                        ],
                        selected: _hintsEnabled,
                        keyFor: (value) =>
                            'memory-hints-${value ? 'on' : 'off'}',
                        onChanged: (value) =>
                            setState(() => _hintsEnabled = value),
                      ),
                      _RulePicker<bool>(
                        compact: compact,
                        title: 'SCORING',
                        choices: const <_RuleChoice<bool>>[
                          _RuleChoice('ON', true),
                          _RuleChoice('OFF', false),
                        ],
                        selected: _scoringEnabled,
                        keyFor: (value) =>
                            'memory-scoring-${value ? 'on' : 'off'}',
                        onChanged: (value) =>
                            setState(() => _scoringEnabled = value),
                      ),
                    ];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'SET THE MEMORY RULES',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.players.length} PLAYERS  ·  ${widget.rounds} ROUNDS  ·  8 PAIRS PER ROUND',
                                style: TextStyle(
                                  color: tokens.muted,
                                  letterSpacing: .8,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: compact ? 6 : 12),
                              if (compact)
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 3,
                                  children: rulePickers
                                      .map(
                                        (picker) => SizedBox(
                                          width:
                                              (constraints.maxWidth - 12).clamp(
                                                0,
                                                920,
                                              ) /
                                              2,
                                          child: picker,
                                        ),
                                      )
                                      .toList(),
                                )
                              else
                                ...rulePickers,
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  onPressed: ready ? _startMatch : null,
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('START MATCH'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: tokens.orange,
                                    foregroundColor: const Color(0xFF08101C),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: compact ? 11 : 18,
                                    ),
                                    shape: const BeveledRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGame(BuildContext context, MemoryGameState state) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final symbols = _symbols;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const V5SceneArt(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xD7051021), Color(0xB9051021)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Exit Memory',
                      onPressed: widget.onExit,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xFFFF9B2F),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MEMORY',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(width: 18),
                    _HudTag(label: 'ROUND ${state.round}/${widget.rounds}'),
                    const Spacer(),
                    _HudTag(
                      label: state.activePlayer.displayName.toUpperCase(),
                    ),
                    if (state.secondsRemaining != null) ...<Widget>[
                      const SizedBox(width: 8),
                      _HudTag(label: '${state.secondsRemaining}s'),
                    ],
                    if (_hintsEnabled == true) ...<Widget>[
                      const SizedBox(width: 6),
                      IconButton(
                        key: const ValueKey<String>('memory-hint'),
                        tooltip: state.hintUsed ? 'Hint used' : 'Reveal a pair',
                        onPressed: state.hintUsed
                            ? null
                            : () => _controller?.useHint(),
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                      ),
                    ],
                  ],
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final ratio =
                          (constraints.maxWidth - 3 * 8) /
                          (constraints.maxHeight - 3 * 8);
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(4),
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: ratio.clamp(1.15, 4.2),
                                ),
                            itemCount: state.cardSymbols.length,
                            itemBuilder: (context, index) {
                              final visible =
                                  state.matchedCardIndices.contains(index) ||
                                  state.flippedCardIndices.contains(index) ||
                                  state.hintedCardIndices.contains(index);
                              final matched = state.matchedCardIndices.contains(
                                index,
                              );
                              final icon = visible
                                  ? symbols[state.cardSymbols[index]]
                                  : Icons.question_mark_rounded;
                              final color = matched
                                  ? tokens.cyan
                                  : state.hintedCardIndices.contains(index)
                                  ? tokens.orange
                                  : const Color(0xFFD8E6F8);
                              return IconButton(
                                key: ValueKey<String>('memory-card-$index'),
                                tooltip: visible
                                    ? 'Revealed memory card'
                                    : 'Reveal memory card',
                                onPressed: visible
                                    ? null
                                    : () => _controller?.flipCard(index),
                                icon: Icon(icon),
                                iconSize: 34,
                                style: IconButton.styleFrom(
                                  foregroundColor: color,
                                  backgroundColor: visible
                                      ? const Color(0xCC10243E)
                                      : const Color(0xB8153150),
                                  disabledBackgroundColor: const Color(
                                    0xCC10243E,
                                  ),
                                  shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(13),
                                      bottomLeft: Radius.circular(13),
                                    ),
                                    side: BorderSide(
                                      color: Color(0x663DC9F5),
                                      width: 1.2,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: Row(
                    children: <Widget>[
                      Text(
                        'PAIRS ${state.matchedCardIndices.length ~/ 2}/8',
                        style: TextStyle(
                          color: tokens.ink,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .9,
                        ),
                      ),
                      const Spacer(),
                      if (_scoringEnabled == true)
                        for (final player in state.players)
                          Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Text(
                              '${player.displayName.toUpperCase()}  ${state.scores[player.id] ?? 0}',
                              style: TextStyle(
                                color: tokens.muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.phase == MemoryGamePhase.wrongPair ||
            state.phase == MemoryGamePhase.winCountdown ||
            state.phase == MemoryGamePhase.complete)
          _OutcomeOverlay(
            state: state,
            onContinue: state.phase == MemoryGamePhase.wrongPair
                ? () => _controller?.continueAfterWrongPair()
                : null,
            onExit: widget.onExit,
          ),
      ],
    );
  }

  Widget _topBar(BuildContext context, String title) => SizedBox(
    height: 48,
    child: Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Back to match setup',
          onPressed: widget.onExit,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Icon(Icons.grid_view_rounded, color: Color(0xFFFF9B2F)),
        const SizedBox(width: 9),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
      ],
    ),
  );
}

class _RuleChoice<T> {
  const _RuleChoice(this.label, this.value);
  final String label;
  final T value;
}

class _RulePicker<T> extends StatelessWidget {
  const _RulePicker({
    required this.compact,
    required this.title,
    required this.choices,
    required this.selected,
    required this.keyFor,
    required this.onChanged,
  });

  final bool compact;
  final String title;
  final List<_RuleChoice<T>> choices;
  final T? selected;
  final String Function(T value) keyFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 1 : 5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: compact ? 112 : 144,
            child: Text(
              title,
              style: TextStyle(
                color: tokens.muted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: .9,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 7,
              runSpacing: 5,
              children: choices
                  .map(
                    (choice) => ChoiceChip(
                      key: ValueKey<String>(keyFor(choice.value)),
                      label: Text(choice.label),
                      selected: selected == choice.value,
                      onSelected: (_) => onChanged(choice.value),
                      visualDensity: compact
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: compact ? 4 : 8,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 3 : 8,
                      ),
                      selectedColor: tokens.orange,
                      backgroundColor: const Color(0x9921334A),
                      labelStyle: TextStyle(
                        color: selected == choice.value
                            ? const Color(0xFF06111F)
                            : tokens.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                      side: BorderSide(
                        color: selected == choice.value
                            ? tokens.orange
                            : tokens.cyan.withValues(alpha: .35),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudTag extends StatelessWidget {
  const _HudTag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xA70B1B30),
      border: const Border(
        left: BorderSide(color: Color(0xFFFF9B2F), width: 2),
      ),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
    ),
  );
}

class _OutcomeOverlay extends StatelessWidget {
  const _OutcomeOverlay({
    required this.state,
    required this.onContinue,
    required this.onExit,
  });
  final MemoryGameState state;
  final VoidCallback? onContinue;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final title = switch (state.phase) {
      MemoryGamePhase.wrongPair => state.notice ?? 'NO MATCH',
      MemoryGamePhase.winCountdown => 'WIN COUNTDOWN',
      MemoryGamePhase.complete => 'SESSION COMPLETE',
      _ => '',
    };
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xB9050D19),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xEF08172B),
              border: Border(
                top: BorderSide(color: Color(0xFFFF9B2F), width: 3),
                left: BorderSide(color: Color(0xFF37C5F4), width: 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                if (state.phase == MemoryGamePhase.winCountdown)
                  Text(
                    '${state.countdownRemaining}',
                    style: const TextStyle(
                      color: Color(0xFFFF9B2F),
                      fontSize: 64,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                if (state.phase == MemoryGamePhase.wrongPair)
                  FilledButton(
                    onPressed: onContinue,
                    child: const Text('CONTINUE TURN'),
                  ),
                if (state.phase == MemoryGamePhase.complete) ...<Widget>[
                  if (state.scores.isNotEmpty) ...<Widget>[
                    const Text('MATCH WINNER'),
                    Text(
                      state.players
                          .firstWhere(
                            (player) =>
                                player.id ==
                                state.scores.entries
                                    .toList()
                                    .reduce(
                                      (a, b) => a.value >= b.value ? a : b,
                                    )
                                    .key,
                          )
                          .displayName,
                      style: const TextStyle(
                        color: Color(0xFF37C5F4),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  TextButton(
                    onPressed: onExit,
                    child: const Text('RETURN TO LOBBY'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _symbols = <IconData>[
  Icons.bolt_rounded,
  Icons.shield_rounded,
  Icons.star_rounded,
  Icons.diamond_rounded,
  Icons.local_fire_department_rounded,
  Icons.hexagon_rounded,
  Icons.flash_on_rounded,
  Icons.circle_rounded,
];
