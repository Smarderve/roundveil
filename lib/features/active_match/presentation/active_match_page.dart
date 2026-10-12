import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';

class ActiveMatchPage extends StatefulWidget {
  const ActiveMatchPage({
    required this.configuration,
    this.enableTimers = true,
    super.key,
  });

  final SessionConfiguration configuration;
  final bool enableTimers;

  @override
  State<ActiveMatchPage> createState() => _ActiveMatchPageState();
}

class _ActiveMatchPageState extends State<ActiveMatchPage> {
  late final ActiveMatchController _match = ActiveMatchController(
    configuration: widget.configuration,
    enableTimers: widget.enableTimers,
  );
  final TextEditingController _answer = TextEditingController();

  @override
  void dispose() {
    _match.dispose();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final compactLandscape = MediaQuery.sizeOf(context).height < 500;
    return AnimatedBuilder(
      animation: _match,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFF05030D),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const Positioned.fill(child: V5SceneArt()),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xE8051022),
                        Color(0xDD0A1C33),
                        Color(0xF205030D),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: compactLandscape ? 8 : 20,
                ),
                child: Column(
                  children: <Widget>[
                    _header(tokens),
                    SizedBox(height: compactLandscape ? 8 : 16),
                    Expanded(child: _body(tokens)),
                    SizedBox(height: compactLandscape ? 8 : 12),
                    _footer(tokens),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(RoundveilBrandTokens tokens) => Row(
    children: <Widget>[
      IconButton(
        tooltip: 'Pause match',
        onPressed: _match.state.phase == MatchPhase.complete
            ? null
            : _match.state.phase == MatchPhase.paused
            ? _match.resume
            : _match.pause,
        icon: Icon(
          _match.state.phase == MatchPhase.paused
              ? Icons.play_arrow_rounded
              : Icons.pause_rounded,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          _moduleTitle(_match.state.challenge.moduleId).toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      Text(
        'ROUND ${_match.state.round}  ·  ${_match.state.activePlayer.displayName.toUpperCase()}',
        style: TextStyle(color: tokens.cyan, fontWeight: FontWeight.w800),
      ),
      const SizedBox(width: 14),
      Text(
        '${_match.state.secondsRemaining}s',
        style: TextStyle(color: tokens.orange),
      ),
    ],
  );

  Widget _body(RoundveilBrandTokens tokens) {
    final state = _match.state;
    if (state.phase == MatchPhase.complete) return _results(tokens);
    if (state.phase == MatchPhase.paused) {
      return _centerMessage('MATCH PAUSED', 'Resume when your squad is ready.');
    }
    if (state.phase == MatchPhase.winCountdown) {
      return _centerMessage('WIN COUNTDOWN', '${state.secondsRemaining}');
    }
    return _challenge(tokens);
  }

  Widget _challenge(RoundveilBrandTokens tokens) {
    final state = _match.state;
    final challenge = state.challenge;
    final color = tokens.cyan;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final flagHeight = (viewportHeight * (state.answerVisible ? 0.10 : 0.18))
        .clamp(64.0, 220.0)
        .toDouble();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (challenge.moduleId == 'guess_country_flags') ...<Widget>[
                if (challenge.flagAssetPath case final asset?)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 560,
                      maxHeight: flagHeight,
                    ),
                    child: SizedBox(
                      height: flagHeight,
                      child: SvgPicture.asset(asset, fit: BoxFit.contain),
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  'SAY THE COUNTRY ALOUD',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                if (state.hintVisible)
                  Text(
                    'HINT · ${challenge.hint}',
                    style: TextStyle(color: tokens.muted),
                  ),
                if (state.answerVisible) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    challenge.answer.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _judgementButtons(tokens),
                ] else
                  FilledButton(
                    onPressed: _match.revealAnswer,
                    child: const Text('REVEAL ANSWER'),
                  ),
              ] else if (challenge.moduleId == 'guess_character') ...<Widget>[
                if (state.phase == MatchPhase.turnAway) ...<Widget>[
                  const Text(
                    'PLAYER — TURN AWAY',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The clue-givers should be ready before revealing the character.',
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _match.revealCharacterAfterPlayerTurnsAway,
                    child: const Text('PLAYER IS TURNED AWAY · REVEAL'),
                  ),
                ] else ...<Widget>[
                  Text(
                    'NAME MODE · SHOW TO CLUE-GIVERS',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    challenge.answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Give verbal clues. Keep the character visible until the host judges the spoken guess.',
                  ),
                  _judgementButtons(tokens),
                ],
              ] else ...<Widget>[
                Text(
                  challenge.prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                if (challenge.moduleId == 'quiz')
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      for (final choice in challenge.choices)
                        SizedBox(
                          width: 260,
                          child: OutlinedButton(
                            onPressed: () => _match.answer(choice),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(choice, textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                    ],
                  )
                else ...<Widget>[
                  TextField(
                    controller: _answer,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      _match.answer(value);
                      _answer.clear();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Your answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      _match.answer(_answer.text);
                      _answer.clear();
                    },
                    child: const Text('SUBMIT WORD'),
                  ),
                ],
                if (state.hintVisible)
                  Text(
                    'HINT · ${challenge.hint}',
                    style: TextStyle(color: tokens.muted),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _judgementButtons(RoundveilBrandTokens tokens) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => _match.judge(correct: true),
          icon: const Icon(Icons.check),
          label: const Text('CORRECT'),
        ),
        OutlinedButton.icon(
          onPressed: () => _match.judge(correct: false),
          icon: const Icon(Icons.close),
          label: const Text('WRONG'),
        ),
      ],
    ),
  );

  Widget _footer(RoundveilBrandTokens tokens) => Row(
    children: <Widget>[
      if (widget.configuration.hintsEnabled)
        TextButton.icon(
          onPressed: _match.revealHint,
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('HINT'),
        ),
      const Spacer(),
      Text(
        'TURN ${_match.state.turnIndex + 1} / ${_match.state.totalTurns}',
        style: TextStyle(color: tokens.muted, fontWeight: FontWeight.w800),
      ),
    ],
  );

  Widget _results(RoundveilBrandTokens tokens) {
    final ordered = _match.state.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'MATCH COMPLETE',
              style: TextStyle(
                color: tokens.orange,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            for (final row in ordered)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                child: Text(
                  '${_playerName(row.key)}  ·  ${row.value} WINS',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text('BACK TO LOBBY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerMessage(String title, String detail) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          detail,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );

  String _playerName(String id) => widget.configuration.players
      .firstWhere((player) => player.id == id)
      .displayName;

  String _moduleTitle(String id) => switch (id) {
    'quiz' => 'Quiz',
    'word_play' => 'Word Play',
    'guess_character' => 'Guess the Character',
    'guess_country_flags' => 'Guess the Country',
    _ => id,
  };
}
