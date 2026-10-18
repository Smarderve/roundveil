import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/data/repositories/challenge_history_repository.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/round_game_format.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/guess_country/presentation/player_avatar_figure.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';

class ActiveMatchPage extends StatefulWidget {
  const ActiveMatchPage({
    required this.configuration,
    this.enableTimers = true,
    this.profileRepository,
    this.challengeHistoryRepository,
    this.characterPictureRepository,
    super.key,
  });

  final SessionConfiguration configuration;
  final bool enableTimers;
  final PlayerProfileRepository? profileRepository;
  final ChallengeHistoryRepository? challengeHistoryRepository;
  final CharacterPictureRepository? characterPictureRepository;

  @override
  State<ActiveMatchPage> createState() => _ActiveMatchPageState();
}

class _ActiveMatchPageState extends State<ActiveMatchPage> {
  ActiveMatchController? _match;
  ActiveMatchController get _activeMatch => _match!;
  late final PlayerProfileRepository _profileRepository;
  late final ChallengeHistoryRepository _challengeHistoryRepository;
  late final CharacterPictureRepository _pictureRepository =
      widget.characterPictureRepository ?? CharacterPictureRepository();
  late Future<void> _startup;
  Object? _startupError;
  final TextEditingController _answer = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileRepository =
        widget.profileRepository ?? InMemoryPlayerProfileRepository();
    _challengeHistoryRepository =
        widget.challengeHistoryRepository ?? LocalChallengeHistoryRepository();
    _startup = _startMatch();
  }

  Future<void> _startMatch() async {
    try {
      final profiles = await _profileRepository.ensureProfiles(
        widget.configuration.players,
      );
      final recentChallengeIds = await _challengeHistoryRepository
          .loadRecentIds();
      final needsPictures = widget.configuration.effectiveRoundFormatIds
          .contains('character_picture');
      final selectedPictureCategory =
          widget.configuration.characterPictureCategory;
      final pictures = needsPictures
          ? await _pictureRepository.loadRenderablePlayable(
              category: selectedPictureCategory == 'All Categories'
                  ? null
                  : selectedPictureCategory,
            )
          : const <CharacterPicture>[];
      if (!mounted) return;
      final match = ActiveMatchController(
        configuration: widget.configuration,
        enableTimers: widget.enableTimers,
        profileRepository: _profileRepository,
        profiles: <String, PlayerProfile>{
          for (final profile in profiles) profile.id: profile,
        },
        recentChallengeIds: recentChallengeIds,
        pictureChallenges: pictures
            .map(
              (picture) => OfflineChallenge(
                id: picture.id,
                prompt: 'Identify the person or character shown.',
                answer: picture.name,
                hint: picture.hint,
                imageFilePath: picture.path,
                imageSource: picture.sourceTitle,
                category: picture.category,
                franchise: picture.franchise,
              ),
            )
            .toList(growable: false),
        objectChallenges: objectChallengeCatalog,
        onChallengeDrawn: (id) {
          unawaited(_recordChallenge(id));
        },
      );
      _match = match;
      match.start();
      setState(() {});
    } on Object catch (error) {
      debugPrint('ROUNDVEIL match startup failed: $error');
      if (!mounted) return;
      _startupError = error;
      setState(() {});
    }
  }

  void _retryStartup() {
    setState(() => _startupError = null);
    _startup = _startMatch();
  }

  Widget _startupFailure(Object error) => Scaffold(
    backgroundColor: const Color(0xFF05030D),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFA24A),
                  size: 44,
                ),
                const SizedBox(height: 12),
                const Text(
                  'MATCH COULD NOT START',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _retryStartup,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('RETRY'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('RETURN'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _recordChallenge(String id) async {
    try {
      await _challengeHistoryRepository.recordUsed(id);
    } on Object catch (error) {
      debugPrint('Could not persist ROUNDVEIL challenge history: $error');
    }
  }

  @override
  void dispose() {
    _match?.dispose();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final compactLandscape = MediaQuery.sizeOf(context).height < 500;
    final match = _match;
    if (match == null) {
      return FutureBuilder<void>(
        future: _startup,
        builder: (context, snapshot) {
          if (_startupError != null) return _startupFailure(_startupError!);
          if (snapshot.hasError) return _startupFailure(snapshot.error!);
          return const Scaffold(
            backgroundColor: Color(0xFF05030D),
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }
    return AnimatedBuilder(
      animation: match,
      builder: (context, _) {
        if (match.state.phase == MatchPhase.winCountdown) {
          return _countdownScreen(
            match.state.secondsRemaining,
            pointsAwarded: match.state.pointsAwarded,
          );
        }
        final showGameplayChrome =
            match.state.phase != MatchPhase.complete &&
            match.state.phase != MatchPhase.completing;
        return Scaffold(
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
                      if (showGameplayChrome) _header(tokens),
                      if (showGameplayChrome)
                        SizedBox(height: compactLandscape ? 8 : 16),
                      Expanded(child: _body(tokens)),
                      if (showGameplayChrome)
                        SizedBox(height: compactLandscape ? 8 : 12),
                      if (showGameplayChrome) _footer(tokens),
                    ],
                  ),
                ),
                if (match.state.hintVisible)
                  Positioned(
                    top: compactLandscape ? 50 : 72,
                    left: 12,
                    right: 12,
                    child: Center(
                      child: _AnswerHintPopup(
                        key: ValueKey<String>(match.state.challenge.id),
                        hint: match.state.hintText,
                        onDismiss: match.dismissHint,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _countdownScreen(int seconds, {required int pointsAwarded}) =>
      Scaffold(
        backgroundColor: const Color(0xFF030916),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -.08),
                    radius: .9,
                    colors: <Color>[
                      Color(0xFF162E4A),
                      Color(0xFF091626),
                      Color(0xFF030916),
                    ],
                  ),
                ),
              ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                        child: Text(
                          '$seconds',
                          key: ValueKey<int>(seconds),
                          style: TextStyle(
                            color: seconds == 0
                                ? const Color(0xFFFF963D)
                                : Colors.white,
                            fontSize: MediaQuery.sizeOf(context).height * .42,
                            height: .9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                            shadows: const <Shadow>[
                              Shadow(color: Color(0x9958D7FF), blurRadius: 42),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'CORRECT',
                        style: TextStyle(
                          color: Color(0xFF6EE7FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      if (pointsAwarded > 0) ...<Widget>[
                        const SizedBox(height: 5),
                        Text(
                          '+$pointsAwarded POINTS',
                          style: const TextStyle(
                            color: Color(0xFFFF963D),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _header(RoundveilBrandTokens tokens) => Row(
    children: <Widget>[
      IconButton(
        tooltip: 'Pause match',
        onPressed: _activeMatch.state.phase == MatchPhase.complete
            ? null
            : _activeMatch.state.phase == MatchPhase.paused
            ? _activeMatch.resume
            : _activeMatch.pause,
        icon: Icon(
          _activeMatch.state.phase == MatchPhase.paused
              ? Icons.play_arrow_rounded
              : Icons.pause_rounded,
        ),
      ),
      const SizedBox(width: 8),
      PlayerAvatarFigure(
        avatarId: _activeMatch
            .state
            .profiles[_activeMatch.state.activePlayer.id]!
            .avatarId,
        appearance: _activeMatch
            .state
            .profiles[_activeMatch.state.activePlayer.id]!
            .avatar,
        width: 34,
        height: 50,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '${_gameFamilyTitle(_activeMatch.state.challenge.formatId)} · ${roundGameFormatById(_activeMatch.state.challenge.formatId)!.title.toUpperCase()}',
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
        'ROUND ${_activeMatch.state.round}  ·  ${_activeMatch.state.activePlayer.displayName.toUpperCase()}',
        style: TextStyle(color: tokens.cyan, fontWeight: FontWeight.w800),
      ),
      const SizedBox(width: 12),
      Text(
        '${_activeMatch.state.scores[_activeMatch.state.activePlayer.id] ?? 0} PTS',
        style: TextStyle(color: tokens.orange, fontWeight: FontWeight.w900),
      ),
      const SizedBox(width: 10),
      Text(
        '${_activeMatch.state.secondsRemaining}s',
        style: TextStyle(color: tokens.orange),
      ),
    ],
  );

  Widget _body(RoundveilBrandTokens tokens) {
    final state = _activeMatch.state;
    if (state.phase == MatchPhase.complete) return _results(tokens);
    if (state.phase == MatchPhase.completing) {
      return _centerMessage('MATCH COMPLETE', 'Recording final standings…');
    }
    if (state.phase == MatchPhase.roundIntro) return _roundIntro(tokens);
    if (state.phase == MatchPhase.playerIntro) return _playerIntro(tokens);
    if (state.phase == MatchPhase.paused) {
      return _paused(tokens);
    }
    return _challenge(tokens);
  }

  Widget _roundIntro(RoundveilBrandTokens tokens) {
    final state = _activeMatch.state;
    final compact = MediaQuery.sizeOf(context).height < 500;
    final format = roundGameFormatById(state.challenge.formatId)!;
    final gameTitle = switch (format.family) {
      RoundGameFamily.quiz => 'QUIZ',
      RoundGameFamily.wordPlay => 'WORD PLAY',
      RoundGameFamily.guessingGames => 'GUESSING GAMES',
    };
    final category = switch (state.challenge.moduleId) {
      'guess_character' => 'CHARACTER',
      'guess_country_flags' => 'COUNTRY',
      'guess_objects' => 'OBJECT',
      _ => null,
    };
    final icon = switch (state.challenge.moduleId) {
      'quiz' => Icons.quiz_rounded,
      'word_play' => Icons.abc_rounded,
      'guess_character' => Icons.person_search_rounded,
      'guess_country_flags' => Icons.flag_rounded,
      'guess_objects' => Icons.inventory_2_rounded,
      _ => Icons.sports_esports_rounded,
    };
    return SingleChildScrollView(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: .92, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'ROUND ${state.round}',
                style: TextStyle(
                  color: tokens.orange,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: compact ? 5 : 12),
              Icon(icon, color: tokens.cyan, size: compact ? 38 : 58),
              SizedBox(height: compact ? 2 : 8),
              Text(
                gameTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 24 : 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              if (category != null)
                Text(
                  category,
                  style: TextStyle(
                    color: tokens.cyan,
                    fontSize: compact ? 10 : 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              SizedBox(height: compact ? 2 : 5),
              Text(
                format.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tokens.orange,
                  fontSize: compact ? 14 : 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: compact ? 3 : 8),
              Text(
                switch (state.challenge.formatId) {
                  'character_name' || 'character_picture' || 'country_name' => 'Each player gets a different challenge. The selected mode stays the same for the whole round.',
                  _ => 'Every player receives a different challenge in this same game format.',
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tokens.muted,
                  fontSize: compact ? 9 : 12,
                ),
              ),
              SizedBox(height: compact ? 3 : 8),
              Text(
                '${widget.configuration.players.length} PLAYERS · ${widget.configuration.roundCount} GAME-WIDE ROUNDS',
                style: TextStyle(
                  color: tokens.muted,
                  fontSize: compact ? 10 : 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: compact ? 8 : 22),
              FilledButton.icon(
                onPressed: _activeMatch.beginRound,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('BEGIN ROUND'),
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(compact ? 40 : 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playerIntro(RoundveilBrandTokens tokens) {
    final state = _activeMatch.state;
    final profile = state.profiles[state.activePlayer.id]!;
    final compact = MediaQuery.sizeOf(context).height < 500;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'TURN ${state.turnIndex + 1} OF ${state.totalTurns} · ROUND ${state.round}',
                style: TextStyle(
                  color: tokens.cyan,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: compact ? 4 : 12),
              PlayerAvatarFigure(
                avatarId: profile.avatarId,
                appearance: profile.avatar,
                width: compact ? 70 : 118,
                height: compact ? 104 : 174,
              ),
              Text(
                profile.displayName.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 20 : 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: compact ? 4 : 8),
              Text(
                '${state.scores[profile.id] ?? 0} MATCH POINTS   ·   ${profile.hintCredits} HINT CREDITS',
                style: TextStyle(
                  color: tokens.orange,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              SizedBox(height: compact ? 8 : 18),
              FilledButton.icon(
                onPressed: _activeMatch.beginChallenge,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('START TURN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _challenge(RoundveilBrandTokens tokens) {
    final state = _activeMatch.state;
    final challenge = state.challenge;
    if (challenge.formatId == 'object_name' ||
        challenge.formatId == 'object_picture') {
      return _objectChallenge(tokens, challenge);
    }
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
              if (challenge.formatId == 'country_flag') ...<Widget>[
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
                  'NAME THE PLACE OR TERRITORY',
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
                    onPressed: _activeMatch.revealAnswer,
                    child: const Text('REVEAL ANSWER'),
                  ),
              ] else if (const <String>{
                'character_name',
                'character_picture',
                'country_name',
                'object_name',
                'object_picture',
              }.contains(challenge.formatId)) ...<Widget>[
                if (state.phase == MatchPhase.turnAway) ...<Widget>[
                  const Text(
                    'PLAYER — TURN AWAY',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    challenge.formatId == 'country_name'
                        ? 'The clue-givers should be ready before revealing the country name.'
                        : challenge.formatId == 'object_name' ||
                              challenge.formatId == 'object_picture'
                        ? 'Clue-givers should be ready before the object is shown.'
                        : 'The clue-givers should be ready before revealing the character.',
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _activeMatch.revealCharacterAfterPlayerTurnsAway,
                    child: Text(
                      challenge.formatId == 'country_name'
                          ? 'PLAYER IS TURNED AWAY · REVEAL COUNTRY'
                          : challenge.formatId == 'object_name' ||
                                challenge.formatId == 'object_picture'
                          ? 'PLAYER IS TURNED AWAY · REVEAL OBJECT'
                          : 'PLAYER IS TURNED AWAY · REVEAL CHARACTER',
                    ),
                  ),
                ] else ...<Widget>[
                  Text(
                    challenge.formatId == 'country_name'
                        ? 'COUNTRY NAME MODE · SHOW TO CLUE-GIVERS'
                        : challenge.formatId == 'object_name'
                        ? 'OBJECT NAME MODE · SHOW TO CLUE-GIVERS'
                        : challenge.formatId == 'object_picture'
                        ? 'OBJECT PICTURE MODE · SHOW TO CLUE-GIVERS'
                        : challenge.formatId == 'character_picture'
                        ? 'PICTURE MODE · SHOW TO CLUE-GIVERS'
                        : 'NAME MODE · SHOW TO CLUE-GIVERS',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (challenge.formatId == 'character_picture' ||
                      challenge.formatId == 'object_picture') ...<Widget>[
                    if (challenge.imageFilePath case final imagePath?)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 560,
                          maxHeight:
                              (viewportHeight *
                                      (challenge.formatId == 'object_picture'
                                          ? .34
                                          : .48))
                                  .clamp(120.0, 360.0)
                                  .toDouble(),
                        ),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stack) =>
                              _unavailablePicture(),
                        ),
                      )
                    else if (challenge.imageAssetPath case final assetPath?)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 680,
                          maxHeight:
                              (viewportHeight *
                                      (challenge.formatId == 'object_picture'
                                          ? .34
                                          : .52))
                                  .clamp(140.0, 420.0)
                                  .toDouble(),
                        ),
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stack) =>
                              _unavailablePicture(),
                        ),
                      )
                    else
                      _unavailablePicture(),
                    if ((challenge.content.franchise ?? '').isNotEmpty ||
                        (challenge.formatId == 'character_picture' &&
                            (challenge.content.category?.isNotEmpty ?? false)))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          <String?>[
                                challenge.content.franchise,
                                challenge.content.category,
                              ]
                              .whereType<String>()
                              .where((value) => value.isNotEmpty)
                              .join(' · '),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tokens.muted, fontSize: 12),
                        ),
                      ),
                  ] else
                    Text(
                      challenge.answer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  if (challenge.formatId == 'character_name' ||
                      challenge.formatId == 'object_name' ||
                      challenge.formatId == 'object_picture') ...<Widget>[
                    const SizedBox(height: 6),
                    if (challenge.formatId == 'object_name' ||
                        challenge.formatId == 'object_picture' ||
                        ((challenge.content.franchise ?? '').isNotEmpty &&
                            challenge.content.franchise!.trim().toLowerCase() !=
                                challenge.answer.trim().toLowerCase()))
                      Text(
                        challenge.formatId == 'object_name' ||
                                challenge.formatId == 'object_picture'
                            ? challenge.content.category ?? 'OBJECT'
                            : challenge.content.franchise!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tokens.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    Text(
                      <String?>[
                            if (challenge.formatId == 'character_name')
                              challenge.content.subjectType,
                            if (challenge.formatId != 'object_name' &&
                                challenge.formatId != 'object_picture')
                              challenge.content.category,
                          ]
                          .whereType<String>()
                          .where((value) => value.isNotEmpty)
                          .join(' · '),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tokens.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(
                        '${challenge.formatId == 'object_name' || challenge.formatId == 'object_picture' ? 'USED FOR' : 'CONTEXT'} · ${challenge.prompt}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    challenge.formatId == 'object_picture'
                        ? 'Give verbal clues from the picture. The host judges the spoken guess.'
                        : challenge.formatId == 'object_name'
                        ? 'Give verbal clues from the object name and context. The host judges the spoken guess.'
                        : 'Give verbal clues. Keep the character visible until the host judges the spoken guess.',
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
                if (challenge.formatId == 'quiz_multiple_choice' ||
                    challenge.formatId == 'quiz_true_false')
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      for (final choice in challenge.choices)
                        SizedBox(
                          width: 260,
                          child: OutlinedButton(
                            onPressed: () => _activeMatch.answer(choice),
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
                      _activeMatch.answer(value);
                      _answer.clear();
                    },
                    decoration: InputDecoration(
                      labelText: challenge.formatId == 'quiz_fill_blank'
                          ? 'Fill in the blank'
                          : challenge.moduleId == 'quiz'
                          ? 'Short answer'
                          : 'Your word',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      _activeMatch.answer(_answer.text);
                      _answer.clear();
                    },
                    child: Text(
                      challenge.moduleId == 'quiz'
                          ? 'SUBMIT ANSWER'
                          : 'SUBMIT WORD',
                    ),
                  ),
                ],
                if (state.hintVisible)
                  Text(
                    'HINT · ${challenge.hint}',
                    style: TextStyle(color: tokens.muted),
                  ),
              ],
              if (state.phase != MatchPhase.turnAway) ...<Widget>[
                const SizedBox(height: 15),
                _circularChallengeTimer(
                  secondsRemaining: state.secondsRemaining,
                  durationSeconds: widget.configuration.challengeSeconds,
                  primaryColor: tokens.cyan,
                  warningColor: tokens.orange,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _objectChallenge(
    RoundveilBrandTokens tokens,
    MatchChallenge challenge,
  ) {
    final state = _activeMatch.state;
    if (state.phase == MatchPhase.turnAway) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'PLAYER — TURN AWAY',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'Clue-givers should be ready before the object is shown.',
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _activeMatch.revealCharacterAfterPlayerTurnsAway,
                child: const Text('PLAYER IS TURNED AWAY · REVEAL OBJECT'),
              ),
            ],
          ),
        ),
      );
    }

    final isPicture = challenge.formatId == 'object_picture';
    final compact = MediaQuery.sizeOf(context).height < 500;
    final imageMaxHeight = (MediaQuery.sizeOf(context).height * .34)
        .clamp(96.0, 300.0)
        .toDouble();
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 62,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        isPicture
                            ? 'OBJECT PICTURE MODE · SHOW TO CLUE-GIVERS'
                            : 'OBJECT NAME MODE · SHOW TO CLUE-GIVERS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tokens.cyan,
                          fontWeight: FontWeight.w900,
                          letterSpacing: compact ? 1 : 1.4,
                          fontSize: compact ? 12 : 14,
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 14),
                      if (isPicture)
                        if (challenge.content.imageFilePath
                            case final imagePath?)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 560,
                              maxHeight: imageMaxHeight,
                            ),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stack) =>
                                  _unavailablePicture(),
                            ),
                          )
                        else if (challenge.content.imageAssetPath
                            case final assetPath?)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 680,
                              maxHeight: imageMaxHeight,
                            ),
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stack) =>
                                  _unavailablePicture(),
                            ),
                          )
                        else
                          _unavailablePicture()
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              challenge.content.answer,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 32 : 42,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: compact ? 4 : 8),
                      Text(
                        challenge.content.category ?? 'OBJECT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tokens.cyan,
                          fontSize: compact ? 13 : 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'USED FOR · ${challenge.content.prompt}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 13 : 16,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 8),
                      Text(
                        isPicture
                            ? 'Give verbal clues from the picture. The host judges the spoken guess.'
                            : 'Give verbal clues from the object name and context. The host judges the spoken guess.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tokens.muted,
                          fontSize: compact ? 11 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _judgementButtons(tokens),
        ],
      ),
    );
  }

  Widget _unavailablePicture() => Container(
    constraints: const BoxConstraints(minHeight: 160, minWidth: 240),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF101A28),
      border: Border.all(color: const Color(0xFFFFA23A)),
    ),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFFFFA23A)),
        SizedBox(height: 10),
        Text(
          'PICTURE UNAVAILABLE',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 4),
        Text(
          'This file could not be opened. Remove it from the library and import a valid image.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _circularChallengeTimer({
    required int secondsRemaining,
    required int durationSeconds,
    required Color primaryColor,
    required Color warningColor,
  }) {
    final target = (secondsRemaining / durationSeconds).clamp(0.0, 1.0);
    final begin = ((secondsRemaining + 1) / durationSeconds).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: target),
      duration: const Duration(seconds: 1),
      curve: Curves.linear,
      builder: (context, progress, _) {
        final warning = secondsRemaining <= 5;
        final color = warning ? warningColor : primaryColor;
        return SizedBox(
          width: 76,
          height: 76,
          child: CustomPaint(
            painter: _ChallengeTimerPainter(progress: progress, color: color),
            child: Center(
              child: Text(
                '$secondsRemaining',
                style: TextStyle(
                  color: warning ? warningColor : Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _judgementButtons(RoundveilBrandTokens tokens) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: <Widget>[
        for (final judgment in const <(bool, String, IconData, Color)>[
          (true, 'CORRECT', Icons.check_rounded, Color(0xFF167A62)),
          (false, 'WRONG', Icons.close_rounded, Color(0xFF9D3542)),
        ])
          SizedBox(
            width: 146,
            height: 46,
            child: FilledButton.icon(
              onPressed: () => _activeMatch.judge(correct: judgment.$1),
              icon: Icon(judgment.$3),
              label: Text(judgment.$2),
              style: FilledButton.styleFrom(
                backgroundColor: judgment.$4,
                foregroundColor: Colors.white,
                elevation: 2,
                animationDuration: const Duration(milliseconds: 120),
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _footer(RoundveilBrandTokens tokens) => Row(
    children: <Widget>[
      if (widget.configuration.hintsEnabled) ...<Widget>[
        TextButton.icon(
          onPressed: _activeMatch.canRevealHint
              ? _activeMatch.revealHint
              : null,
          icon: const Icon(Icons.lightbulb_outline),
          label: Text(
            'HINT · ${_activeMatch.state.profiles[_activeMatch.state.activePlayer.id]?.hintCredits ?? 0}',
          ),
        ),
      ],
      const Spacer(),
      Text(
        'TURN ${_activeMatch.state.turnIndex + 1} / ${_activeMatch.state.totalTurns}',
        style: TextStyle(color: tokens.muted, fontWeight: FontWeight.w800),
      ),
    ],
  );

  Widget _results(RoundveilBrandTokens tokens) {
    final rankings = _activeMatch.state.rankings;
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
            for (final row in rankings)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 44,
                        child: Text(
                          '#${row.rank}',
                          style: TextStyle(
                            color: row.rank == 1 ? tokens.orange : tokens.cyan,
                            fontSize: row.rank == 1 ? 22 : 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      PlayerAvatarFigure(
                        avatarId:
                            _activeMatch.state.profiles[row.playerId]!.avatarId,
                        appearance:
                            _activeMatch.state.profiles[row.playerId]!.avatar,
                        width: 28,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _playerName(row.playerId).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${row.correctAnswers} CORRECT  ·  ${row.wrongAnswers} WRONG  ·  ${row.timeouts} TIMEOUTS',
                              style: TextStyle(
                                color: tokens.muted,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${row.matchPoints} PTS',
                        style: TextStyle(
                          color: tokens.orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '+${row.hintCreditsAwarded} HINTS',
                        style: TextStyle(
                          color: tokens.cyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  key: const ValueKey<String>('play-again'),
                  onPressed: _playAgain,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('PLAY AGAIN'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(160, 44),
                  ),
                ),
                OutlinedButton.icon(
                  key: const ValueKey<String>('results-home'),
                  onPressed: _returnHome,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('HOME'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 44),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _playAgain() {
    _replaceWithFreshMatch();
  }

  void _restartMatch() {
    if (_activeMatch.state.phase == MatchPhase.complete) return;
    _replaceWithFreshMatch();
  }

  void _replaceWithFreshMatch() {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => ActiveMatchPage(
          configuration: widget.configuration,
          enableTimers: widget.enableTimers,
          profileRepository: _profileRepository,
          challengeHistoryRepository: _challengeHistoryRepository,
          characterPictureRepository: _pictureRepository,
        ),
      ),
    );
  }

  void _returnHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _quitGame() {
    if (Platform.isWindows) exit(0);
  }

  Widget _paused(RoundveilBrandTokens tokens) => SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.pause_circle_filled_rounded,
                color: tokens.orange,
                size: 64,
              ),
              const SizedBox(height: 12),
              const Text(
                'MATCH PAUSED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Resume when your squad is ready.',
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.muted),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: <Widget>[
                  FilledButton.icon(
                    key: const ValueKey<String>('resume-match'),
                    onPressed: _activeMatch.resume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('RESUME'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey<String>('restart-match'),
                    onPressed: _restartMatch,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('RESTART'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey<String>('leave-match'),
                    onPressed: _returnHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('LEAVE MATCH'),
                  ),
                  if (Platform.isWindows)
                    TextButton.icon(
                      key: const ValueKey<String>('quit-game'),
                      onPressed: _quitGame,
                      icon: const Icon(Icons.exit_to_app_rounded),
                      label: const Text('QUIT GAME'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

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

  String _gameFamilyTitle(String formatId) =>
      switch (roundGameFormatById(formatId)?.family) {
        RoundGameFamily.quiz => 'QUIZ',
        RoundGameFamily.wordPlay => 'WORD PLAY',
        RoundGameFamily.guessingGames => 'GUESSING GAMES',
        null => 'ROUNDVEIL',
      };
}

class _AnswerHintPopup extends StatefulWidget {
  const _AnswerHintPopup({
    required this.hint,
    required this.onDismiss,
    super.key,
  });

  final String hint;
  final VoidCallback onDismiss;

  @override
  State<_AnswerHintPopup> createState() => _AnswerHintPopupState();
}

class _AnswerHintPopupState extends State<_AnswerHintPopup> {
  static const _duration = Duration(seconds: 6);
  Timer? _timer;
  Timer? _exitTimer;
  int _remainingTenths = 60;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(milliseconds: _duration.inMilliseconds ~/ 60),
      (timer) {
        if (!mounted || _remainingTenths <= 1) {
          timer.cancel();
          _close();
        } else {
          setState(() => _remainingTenths--);
        }
      },
    );
  }

  void _close() {
    if (_exiting) return;
    setState(() => _exiting = true);
    _timer?.cancel();
    _exitTimer = Timer(const Duration(milliseconds: 190), widget.onDismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedSlide(
    offset: _exiting ? const Offset(0, -0.08) : Offset.zero,
    duration: const Duration(milliseconds: 180),
    child: AnimatedOpacity(
      opacity: _exiting ? 0 : 1,
      duration: const Duration(milliseconds: 180),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Material(
          color: const Color(0xFF111D33),
          elevation: 18,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF4EB9F5), width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 6, 8),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFFFB34D),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ANSWER HINT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(_remainingTenths / 10).ceil()}s',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    IconButton(
                      tooltip: 'Close hint',
                      visualDensity: VisualDensity.compact,
                      onPressed: _close,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: Text(
                  widget.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              LinearProgressIndicator(
                value: _remainingTenths / 60,
                minHeight: 3,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF4EB9F5),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ChallengeTimerPainter extends CustomPainter {
  const _ChallengeTimerPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = const Color(0xFF26374A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      -math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      ring,
    );
  }

  @override
  bool shouldRepaint(_ChallengeTimerPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
