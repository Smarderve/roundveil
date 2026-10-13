import 'package:flutter/material.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/data/repositories/challenge_history_repository.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/round_game_format.dart';
import 'package:roundveil/features/active_match/presentation/active_match_page.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';

class CinematicSessionBuilderPage extends StatefulWidget {
  const CinematicSessionBuilderPage({
    required this.drafts,
    this.profileRepository,
    this.challengeHistoryRepository,
    required this.onBack,
    this.initial,
    this.initialName = '',
    this.templateId,
    this.draftId,
    super.key,
  });

  final DraftRepository drafts;
  final PlayerProfileRepository? profileRepository;
  final ChallengeHistoryRepository? challengeHistoryRepository;
  final VoidCallback onBack;
  final SessionConfiguration? initial;
  final String initialName;
  final String? templateId;
  final String? draftId;

  @override
  State<CinematicSessionBuilderPage> createState() =>
      _CinematicSessionBuilderPageState();
}

class _CinematicSessionBuilderPageState
    extends State<CinematicSessionBuilderPage> {
  late final SessionBuilderController _controller = SessionBuilderController(
    drafts: widget.drafts,
    initial: widget.initial,
    templateId: widget.templateId,
    draftId: widget.draftId,
    name: widget.initialName,
  );
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const V5SceneArt(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color(0xB8051228),
                Color(0xEA061226),
                Color(0xFA030916),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _matchBuilder(size, tokens),
        ),
      ],
    );
  }

  Widget _matchBuilder(Size size, RoundveilBrandTokens tokens) {
    final l10n = AppLocalizations.of(context)!;
    final config = _controller.configuration;
    final compact = size.height < 580 || size.width < 820;
    final canBuild = _controller.canCreate;
    final canStart = _controller.canStartMatch;
    final selected = config.selectedModuleIds.toSet();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 30,
        8,
        compact ? 12 : 30,
        compact ? 4 : 10,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: widget.onBack,
                tooltip: l10n.back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.templateId == null
                      ? l10n.createGame.toUpperCase()
                      : l10n.quickGame.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(
                width: compact ? 170 : 250,
                child: TextField(
                  controller: _name,
                  onChanged: _controller.setName,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.sessionName,
                    border: const UnderlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _FormatToggle(
                mixed: config.isMixed,
                onSingle: () => _controller.setFormat(SessionFormat.single),
                onMixed: () => _controller.setFormat(SessionFormat.mixed),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 720) {
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 330,
                          child: _ModuleForge(
                            selected: selected,
                            mixed: config.isMixed,
                            selectedFormatIds: config.effectiveRoundFormatIds
                                .toSet(),
                            onSelect: _controller.toggleGame,
                            onFormatSelect: _controller.toggleRoundFormat,
                            onRemoveUnsupportedFormat:
                                _controller.removeUnsupportedRoundFormat,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 220,
                          child: _SquadForge(
                            players: config.players,
                            rounds: config.roundCount,
                            onAdd: _controller.addPlayer,
                            onRemove: _controller.removePlayer,
                            onRounds: _controller.setRoundCount,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 260,
                          child: _MatchRulesRail(
                            config: config,
                            selectedNames: config.selectedModuleIds.map((id) {
                              final game = gameCatalog.firstWhere(
                                (item) => item.id == id,
                              );
                              return _title(l10n, game.titleKey);
                            }).toList(),
                            onChallengeSeconds: _controller.setChallengeSeconds,
                            onCountdownSeconds:
                                _controller.setWinCountdownSeconds,
                            onHints: _controller.setHintsEnabled,
                            onScoring: _controller.setScoringEnabled,
                            onPointsPerCorrect:
                                _controller.setPointsPerCorrectAnswer,
                            onCountryRegion: _controller.setCountryRegion,
                            onCountryDifficulty:
                                _controller.setCountryDifficulty,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 11,
                      child: _ModuleForge(
                        selected: selected,
                        mixed: config.isMixed,
                        selectedFormatIds: config.effectiveRoundFormatIds
                            .toSet(),
                        onSelect: _controller.toggleGame,
                        onFormatSelect: _controller.toggleRoundFormat,
                        onRemoveUnsupportedFormat:
                            _controller.removeUnsupportedRoundFormat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 9,
                      child: _SquadForge(
                        players: config.players,
                        rounds: config.roundCount,
                        onAdd: _controller.addPlayer,
                        onRemove: _controller.removePlayer,
                        onRounds: _controller.setRoundCount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 7,
                      child: _MatchRulesRail(
                        config: config,
                        selectedNames: config.selectedModuleIds.map((id) {
                          final game = gameCatalog.firstWhere(
                            (item) => item.id == id,
                          );
                          return _title(l10n, game.titleKey);
                        }).toList(),
                        onChallengeSeconds: _controller.setChallengeSeconds,
                        onCountdownSeconds: _controller.setWinCountdownSeconds,
                        onHints: _controller.setHintsEnabled,
                        onScoring: _controller.setScoringEnabled,
                        onPointsPerCorrect:
                            _controller.setPointsPerCorrectAnswer,
                        onCountryRegion: _controller.setCountryRegion,
                        onCountryDifficulty: _controller.setCountryDifficulty,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              if (_controller.startValidationMessage != null)
                Expanded(
                  child: Text(
                    _controller.startValidationMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.muted, fontSize: 10),
                  ),
                )
              else
                const Spacer(),
              TextButton.icon(
                onPressed: canBuild ? _saveDraft : null,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: Text(
                  widget.templateId == null
                      ? l10n.saveDraft.toUpperCase()
                      : 'SAVE AS NEW DRAFT',
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: canStart ? _createSession : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  widget.templateId == null ? 'PREPARE MATCH' : 'START MATCH',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.orange,
                  foregroundColor: const Color(0xFF16100A),
                  minimumSize: const Size(160, 48),
                  shape: const _AngledButtonShape(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveDraft() async {
    final draft = await _controller.saveDraft();
    if (!mounted || draft == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.draftSaved)),
    );
  }

  Future<void> _createSession() async {
    final configuration = await _controller.startMatch();
    if (!mounted || configuration == null) return;
    if (configuration.effectiveRoundFormatIds.contains('character_picture')) {
      final pictures = await CharacterPictureRepository().loadAll();
      if (!mounted) return;
      final issue = ActiveMatchController.validateConfiguration(
        configuration,
        pictureChallenges: pictures
            .map(
              (picture) => OfflineChallenge(
                id: picture.id,
                prompt: 'Identify the person or character shown.',
                answer: picture.name,
                hint: picture.hint,
                imageFilePath: picture.path,
                imageSource: picture.sourceTitle,
              ),
            )
            .toList(growable: false),
      );
      if (issue != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(issue)));
        return;
      }
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ActiveMatchPage(
          configuration: configuration,
          profileRepository: widget.profileRepository,
          challengeHistoryRepository: widget.challengeHistoryRepository,
        ),
      ),
    );
  }
}

class _FormatToggle extends StatelessWidget {
  const _FormatToggle({
    required this.mixed,
    required this.onSingle,
    required this.onMixed,
  });
  final bool mixed;
  final VoidCallback onSingle;
  final VoidCallback onMixed;
  @override
  Widget build(BuildContext context) => SegmentedButton<bool>(
    segments: const <ButtonSegment<bool>>[
      ButtonSegment<bool>(value: false, label: Text('SINGLE')),
      ButtonSegment<bool>(value: true, label: Text('MIXED')),
    ],
    selected: <bool>{mixed},
    onSelectionChanged: (values) => values.single ? onMixed() : onSingle(),
    showSelectedIcon: false,
  );
}

class _ModuleForge extends StatelessWidget {
  const _ModuleForge({
    required this.selected,
    required this.mixed,
    required this.selectedFormatIds,
    required this.onSelect,
    required this.onFormatSelect,
    required this.onRemoveUnsupportedFormat,
  });
  final Set<String> selected;
  final bool mixed;
  final Set<String> selectedFormatIds;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onFormatSelect;
  final ValueChanged<String> onRemoveUnsupportedFormat;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    Widget moduleSlot(String id) {
      final game = gameCatalog.firstWhere((item) => item.id == id);
      return _ModuleSlot(
        title: _title(l10n, game.titleKey),
        status: game.playable ? l10n.playablePrototype : l10n.inFoundation,
        icon: _gameIcon(game.id),
        selected: selected.contains(game.id),
        available: game.playable,
        color: game.playable ? tokens.orange : tokens.cyan,
        onTap: () => onSelect(game.id),
      );
    }

    Widget familyHeading(String value) => Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 3),
      child: Text(
        value,
        style: TextStyle(
          color: tokens.cyan,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ForgeHeading(
          icon: Icons.sports_esports_rounded,
          title: mixed ? 'BUILD YOUR PLAYLIST' : 'CHOOSE THE GAME',
          subtitle: mixed
              ? 'MIXED GAMES IS THE CROSS-GAME MODE'
              : 'SAME GAME THROUGHOUT',
        ),
        if (selected.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'ROUND FORMATS · ONE SHARED FORMAT PER ROUND',
            style: TextStyle(
              color: tokens.cyan,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 58,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 5,
                runSpacing: 3,
                children: <Widget>[
                  for (final option in roundGameFormats.where(
                    (format) => selected.contains(format.moduleId),
                  ))
                    Tooltip(
                      message: option.available
                          ? option.title
                          : option.unavailableReason ?? 'Not installed',
                      child: FilterChip(
                        key: ValueKey<String>('round-format-${option.id}'),
                        label: Text(option.title.toUpperCase()),
                        selected: selectedFormatIds.contains(option.id),
                        onSelected: option.available
                            ? (_) => onFormatSelect(option.id)
                            : selectedFormatIds.contains(option.id)
                            ? (_) => onRemoveUnsupportedFormat(option.id)
                            : null,
                        visualDensity: VisualDensity.compact,
                        labelStyle: const TextStyle(fontSize: 9),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (selectedFormatIds.any((id) => roundGameFormatById(id) == null))
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              const Text('This draft has unknown round formats.'),
              for (final id in selectedFormatIds.where(
                (id) => roundGameFormatById(id) == null,
              ))
                TextButton(
                  onPressed: () => onRemoveUnsupportedFormat(id),
                  child: Text('REMOVE $id'),
                ),
            ],
          ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              familyHeading('QUIZ'),
              moduleSlot('quiz'),
              familyHeading('WORD PLAY'),
              moduleSlot('word_play'),
              familyHeading('GUESSING GAMES'),
              Row(
                children: <Widget>[
                  Expanded(child: moduleSlot('guess_character')),
                  const SizedBox(width: 7),
                  Expanded(child: moduleSlot('guess_country_flags')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SquadForge extends StatelessWidget {
  const _SquadForge({
    required this.players,
    required this.rounds,
    required this.onAdd,
    required this.onRemove,
    required this.onRounds,
  });
  final List<PlayerConfiguration> players;
  final int rounds;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<int> onRounds;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ForgeHeading(
          icon: Icons.groups_rounded,
          title: 'SQUAD & ROUNDS',
          subtitle: 'BUILD A LOCAL PARTY',
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            IconButton(
              tooltip: l10n.removePlayer,
              onPressed: players.isEmpty ? null : onRemove,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (var i = 0; i < players.length; i++)
                    _PlayerToken(index: i + 1, name: players[i].displayName),
                  if (players.isEmpty)
                    Text(
                      l10n.choosePlayer,
                      style: TextStyle(color: tokens.muted, fontSize: 11),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.addPlayer,
              onPressed: players.length >= 12 ? null : onAdd,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'ROUND COUNT',
                style: TextStyle(
                  color: tokens.muted,
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            DropdownButton<int>(
              key: const ValueKey<String>('round-count'),
              value: rounds == 0 ? null : rounds,
              hint: Text(l10n.rounds.toUpperCase()),
              items: List<DropdownMenuItem<int>>.generate(
                10,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value != null) onRounds(value);
              },
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: tokens.orange, width: 3)),
            color: const Color(0x660A1930),
          ),
          child: Text(
            '${players.length} ${l10n.players.toUpperCase()}  ·  ${rounds == 0 ? '—' : rounds} ${l10n.rounds.toUpperCase()}',
            style: TextStyle(
              color: tokens.ink,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchRulesRail extends StatelessWidget {
  const _MatchRulesRail({
    required this.config,
    required this.selectedNames,
    required this.onChallengeSeconds,
    required this.onCountdownSeconds,
    required this.onHints,
    required this.onScoring,
    required this.onPointsPerCorrect,
    required this.onCountryRegion,
    required this.onCountryDifficulty,
  });
  final SessionConfiguration config;
  final List<String> selectedNames;
  final ValueChanged<int> onChallengeSeconds;
  final ValueChanged<int> onCountdownSeconds;
  final ValueChanged<bool> onHints;
  final ValueChanged<bool> onScoring;
  final ValueChanged<int> onPointsPerCorrect;
  final ValueChanged<String> onCountryRegion;
  final ValueChanged<String> onCountryDifficulty;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ForgeHeading(
            icon: Icons.tune_rounded,
            title: 'MATCH RULES',
            subtitle: '${selectedNames.length} ${l10n.selected.toUpperCase()}',
          ),
          const SizedBox(height: 12),
          for (final name in selectedNames)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: <Widget>[
                  Icon(Icons.check_rounded, color: tokens.orange, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            config.isMixed
                ? 'PLAYLIST ORDER FOLLOWS SELECTION'
                : 'MODULE RULES',
            style: TextStyle(
              color: tokens.muted,
              fontSize: 9,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'CHALLENGE TIMER',
                  style: TextStyle(
                    color: tokens.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              DropdownButton<int>(
                key: const ValueKey<String>('challenge-timer'),
                value: config.challengeSeconds,
                items: const <int>[15, 30, 45, 60]
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('${value}s'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onChallengeSeconds(value);
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'WIN COUNTDOWN',
                  style: TextStyle(
                    color: tokens.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              DropdownButton<int>(
                key: const ValueKey<String>('win-countdown'),
                value: config.winCountdownSeconds,
                items: const <int>[3, 5, 10]
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('${value}s'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onCountdownSeconds(value);
                },
              ),
            ],
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'HINTS',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
            ),
            value: config.hintsEnabled,
            onChanged: onHints,
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'SCOREKEEPING',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
            ),
            value: config.scoringEnabled,
            onChanged: onScoring,
          ),
          if (config.scoringEnabled)
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'POINTS PER CORRECT ANSWER',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                ),
                DropdownButton<int>(
                  key: const ValueKey<String>('points-per-correct'),
                  value: config.pointsPerCorrectAnswer,
                  items: const <int>[1, 2, 3, 5, 10, 25]
                      .map(
                        (value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onPointsPerCorrect(value);
                  },
                ),
              ],
            ),
          if (config.selectedModuleIds.contains(
            'guess_country_flags',
          )) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'FLAG SCOPE · UN MEMBERS ONLY',
              style: TextStyle(
                color: tokens.cyan,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text('REGION', style: TextStyle(fontSize: 9)),
                ),
                DropdownButton<String>(
                  key: const ValueKey<String>('country-region'),
                  value: config.countryRegion,
                  items:
                      const <String>[
                            'worldwide',
                            'africa',
                            'asia',
                            'europe',
                            'oceania',
                            'northAmerica',
                            'southAmerica',
                            'other',
                          ]
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toUpperCase()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onCountryRegion(value);
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text('DIFFICULTY', style: TextStyle(fontSize: 9)),
                ),
                DropdownButton<String>(
                  key: const ValueKey<String>('country-difficulty'),
                  value: config.countryDifficulty,
                  items:
                      const <String>[
                            'mixed',
                            'easy',
                            'medium',
                            'hard',
                            'expert',
                          ]
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toUpperCase()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onCountryDifficulty(value);
                  },
                ),
              ],
            ),
          ],
          if (config.selectedModuleIds.contains('guess_character'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'CHARACTER MODE · NAME ONLY  |  PICTURE MODE NOT IN VERIFIED OFFLINE PACK',
                style: TextStyle(
                  color: tokens.muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModuleSlot extends StatelessWidget {
  const _ModuleSlot({
    required this.title,
    required this.status,
    required this.icon,
    required this.selected,
    required this.available,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String status;
  final IconData icon;
  final bool selected;
  final bool available;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected ? color.withValues(alpha: .18) : const Color(0x880A1930),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? color : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(
                color: color.withValues(alpha: selected ? .75 : .2),
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: selected ? color : const Color(0xFF9BAAC0),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: available ? color : const Color(0xFF9BAAC0),
                        fontSize: 7,
                        letterSpacing: .4,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_rounded, color: color, size: 17),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PlayerToken extends StatelessWidget {
  const _PlayerToken({required this.index, required this.name});
  final int index;
  final String name;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xB30B1C34),
        border: Border(
          bottom: BorderSide(color: tokens.cyan.withValues(alpha: .7)),
        ),
      ),
      child: Text(
        '${index.toString().padLeft(2, '0')}  ${name.toUpperCase()}',
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ForgeHeading extends StatelessWidget {
  const _ForgeHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Row(
      children: <Widget>[
        Icon(icon, color: tokens.orange, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: tokens.cyan,
                  fontSize: 8,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AngledButtonShape extends OutlinedBorder {
  const _AngledButtonShape();
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  ShapeBorder scale(double t) => this;
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..moveTo(rect.left + 12, rect.top)
    ..lineTo(rect.right, rect.top)
    ..lineTo(rect.right, rect.bottom - 12)
    ..lineTo(rect.right - 12, rect.bottom)
    ..lineTo(rect.left, rect.bottom)
    ..lineTo(rect.left, rect.top + 12)
    ..close();
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
  @override
  _AngledButtonShape copyWith({BorderSide? side}) => this;
}

IconData _gameIcon(String id) => switch (id) {
  'quiz' => Icons.quiz_outlined,
  'word_play' => Icons.text_fields_rounded,
  'guess_character' => Icons.person_search_outlined,
  'guess_country_flags' => Icons.flag_outlined,
  _ => Icons.sports_esports_outlined,
};

String _title(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quiz,
  'wordPlay' => l10n.wordPlay,
  'guessCharacter' => l10n.guessCharacter,
  'guessCountry' => l10n.guessCountry,
  'quickQuiz' => l10n.quickQuiz,
  'quickWordPlay' => l10n.quickWordPlay,
  'quickCharacter' => l10n.quickCharacter,
  'quickFlags' => l10n.quickFlags,
  'quickPartyMix' => l10n.quickPartyMix,
  _ => key,
};
