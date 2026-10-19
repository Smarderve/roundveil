import 'package:flutter/material.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/data/repositories/challenge_history_repository.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/round_game_format.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/features/active_match/presentation/active_match_page.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';
import 'package:roundveil/features/guess_country/presentation/player_avatar_figure.dart';

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
  List<PlayerProfile> _savedProfiles = const <PlayerProfile>[];
  List<OfflineChallenge> _pictureChallenges = const <OfflineChallenge>[];
  bool _pictureLibraryLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _loadPictureLibrary();
  }

  Future<void> _loadPictureLibrary() async {
    try {
      final pictures = await CharacterPictureRepository().loadPlayable();
      if (mounted) {
        setState(() {
          _pictureChallenges = _pictureChallengesFrom(pictures);
          _pictureLibraryLoaded = true;
        });
      }
    } on Object {
      if (mounted) setState(() => _pictureLibraryLoaded = true);
    }
  }

  List<OfflineChallenge> _pictureChallengesFrom(
    Iterable<CharacterPicture> pictures,
  ) => pictures
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
      .toList(growable: false);

  String? _pictureConfigurationIssue(SessionConfiguration configuration) {
    if (!configuration.effectiveRoundFormatIds.contains('character_picture')) {
      return null;
    }
    if (!_pictureLibraryLoaded) return 'CHECKING LOCAL PICTURE COLLECTION…';
    return ActiveMatchController.validateConfiguration(
      configuration,
      pictureChallenges: _pictureChallenges,
    );
  }

  Future<void> _loadProfiles() async {
    final repository = widget.profileRepository;
    if (repository == null) return;
    try {
      final profiles = await repository.loadAll();
      if (mounted) setState(() => _savedProfiles = profiles);
    } on Object {
      // Keep setup usable if local profile storage is temporarily unavailable.
    }
  }

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
    final pictureIssue = _pictureConfigurationIssue(config);
    final canStart = _controller.canStartMatch && pictureIssue == null;
    final gameChoice = _choiceFor(config);
    final selectedNames = config.selectedModuleIds.map((id) {
      final game = gameCatalog.firstWhere((item) => item.id == id);
      return _title(l10n, game.titleKey);
    }).toList();
    final contentWidth = size.width < 1000 ? size.width * .84 : 1040.0;
    final choiceHeight = compact ? 48.0 : 64.0;
    final playersHeight = compact ? 78.0 : 116.0;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: contentWidth,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 12 : 32,
            4,
            compact ? 12 : 32,
            8,
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: compact ? 35 : 48,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: widget.onBack,
                      tooltip: l10n.back,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.templateId == null
                            ? l10n.createGame.toUpperCase()
                            : l10n.quickGame.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: compact ? 17 : 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    if (widget.templateId != null)
                      _FormatToggle(
                        mixed: config.isMixed,
                        onSingle: () =>
                            _controller.setFormat(SessionFormat.single),
                        onMixed: () =>
                            _controller.setFormat(SessionFormat.mixed),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentWidth,
                      maxHeight: size.height * (compact ? .76 : .72),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: compact ? 3 : 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _LobbySectionLabel(
                            title: 'CHOOSE YOUR GAME',
                            detail:
                                'ONE CLEAR CHOICE. START WHEN YOU ARE READY.',
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 4 : 8),
                          SizedBox(
                            height: choiceHeight,
                            child: Row(
                              children: <Widget>[
                                for (final choice
                                    in _MatchChoice.values) ...<Widget>[
                                  if (choice != _MatchChoice.values.first)
                                    SizedBox(width: compact ? 4 : 8),
                                  Expanded(
                                    child: _MatchChoiceButton(
                                      choice: choice,
                                      selected: gameChoice == choice,
                                      compact: compact,
                                      onTap: () => _selectChoice(choice),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 7 : 14),
                          _LobbySectionLabel(
                            title: 'PLAYERS',
                            detail: '${config.players.length} SELECTED',
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 3 : 7),
                          SizedBox(
                            height: playersHeight,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: ListView.separated(
                                    key: const ValueKey<String>(
                                      'selected-players',
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: config.players.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: compact ? 5 : 9),
                                    itemBuilder: (context, index) {
                                      final player = config.players[index];
                                      final profile = _savedProfiles
                                          .where((item) => item.id == player.id)
                                          .firstOrNull;
                                      return _SelectedPlayer(
                                        player: player,
                                        profile: profile,
                                        compact: compact,
                                        onRemove: () => _controller.setPlayers(
                                          config.players
                                              .where(
                                                (item) => item.id != player.id,
                                              )
                                              .toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: compact ? 5 : 12),
                                OutlinedButton.icon(
                                  key: const ValueKey<String>(
                                    'choose-saved-players',
                                  ),
                                  onPressed: _choosePlayers,
                                  icon: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                  ),
                                  label: Text(
                                    compact ? 'SELECT' : 'SELECT PLAYERS',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 7 : 14),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _LobbySectionLabel(
                                  title: 'ROUNDS',
                                  detail: 'ONE FORMAT FOR EVERY PLAYER',
                                  compact: compact,
                                ),
                              ),
                              DropdownButton<int>(
                                key: const ValueKey<String>('round-count'),
                                value: config.roundCount == 0
                                    ? null
                                    : config.roundCount,
                                hint: const Text('CHOOSE'),
                                items: List<DropdownMenuItem<int>>.generate(
                                  10,
                                  (index) => DropdownMenuItem<int>(
                                    value: index + 1,
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    _controller.setRoundCount(value);
                                  }
                                },
                              ),
                            ],
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              splashColor: tokens.cyan.withValues(alpha: .08),
                            ),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(
                                'ADVANCED SETTINGS',
                                style: TextStyle(
                                  color: tokens.cyan,
                                  fontSize: compact ? 10 : 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              subtitle: Text(
                                'Formats, timers, hints, scoring and more',
                                style: TextStyle(
                                  color: tokens.muted,
                                  fontSize: compact ? 9 : 10,
                                ),
                              ),
                              children: <Widget>[
                                TextField(
                                  controller: _name,
                                  onChanged: _controller.setName,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: l10n.sessionName,
                                    labelText: 'MATCH NAME',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _RoundFormatPicker(
                                  selectedModules: config.selectedModuleIds
                                      .toSet(),
                                  selectedFormatIds: config
                                      .effectiveRoundFormatIds
                                      .toSet(),
                                  onToggle: _controller.toggleRoundFormat,
                                ),
                                const SizedBox(height: 10),
                                _MatchRulesRail(
                                  config: config,
                                  selectedNames: selectedNames,
                                  onChallengeSeconds:
                                      _controller.setChallengeSeconds,
                                  onCountdownSeconds:
                                      _controller.setWinCountdownSeconds,
                                  onHints: _controller.setHintsEnabled,
                                  onScoring: _controller.setScoringEnabled,
                                  onPointsPerCorrect:
                                      _controller.setPointsPerCorrectAnswer,
                                  onCountryRegion: _controller.setCountryRegion,
                                  onCountryDifficulty:
                                      _controller.setCountryDifficulty,
                                  onCharacterPictureCategory:
                                      _controller.setCharacterPictureCategory,
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
              SizedBox(height: compact ? 3 : 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      canStart
                          ? 'MATCH READY'
                          : (pictureIssue ??
                                _controller.startValidationMessage ??
                                'CHOOSE A GAME, PLAYERS AND ROUNDS'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: canStart ? tokens.cyan : tokens.muted,
                        fontSize: compact ? 9 : 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: canBuild ? _saveDraft : null,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: Text(
                      widget.templateId == null
                          ? l10n.saveDraft.toUpperCase()
                          : 'SAVE DRAFT',
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton.icon(
                    key: const ValueKey<String>('start-match'),
                    onPressed: canStart ? _createSession : null,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('START GAME'),
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.orange,
                      foregroundColor: const Color(0xFF16100A),
                      minimumSize: Size(compact ? 130 : 180, compact ? 40 : 50),
                      shape: const _AngledButtonShape(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _MatchChoice? _choiceFor(SessionConfiguration config) {
    if (config.isMixed) return _MatchChoice.mixed;
    if (config.selectedModuleIds.length == 1) {
      return switch (config.selectedModuleIds.single) {
        'quiz' => _MatchChoice.quiz,
        'word_play' => _MatchChoice.wordPlay,
        _ => _MatchChoice.guessing,
      };
    }
    if (config.selectedModuleIds.isNotEmpty &&
        config.selectedModuleIds.every(
          (id) => id == 'guess_character' || id == 'guess_country_flags',
        )) {
      return _MatchChoice.guessing;
    }
    return null;
  }

  void _selectChoice(_MatchChoice choice) {
    final modules = switch (choice) {
      _MatchChoice.quiz => const <String>['quiz'],
      _MatchChoice.wordPlay => const <String>['word_play'],
      _MatchChoice.guessing => const <String>[
        'guess_character',
        'guess_country_flags',
      ],
      _MatchChoice.mixed => const <String>[
        'quiz',
        'word_play',
        'guess_character',
        'guess_country_flags',
      ],
    };
    _controller.setGameSelection(
      moduleIds: modules,
      mixed: choice == _MatchChoice.mixed,
    );
  }

  Future<void> _choosePlayers() async {
    if (widget.profileRepository == null) {
      _controller.addPlayer();
      return;
    }
    final profiles = _savedProfiles.isNotEmpty
        ? _savedProfiles
        : await widget.profileRepository!.loadAll();
    if (!mounted) return;
    if (profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create a saved player in Avatars before starting a match.',
          ),
        ),
      );
      return;
    }
    final selectedIds = _controller.configuration.players
        .map((player) => player.id)
        .toSet();
    final result = await showDialog<List<PlayerConfiguration>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('CHOOSE YOUR PLAYERS'),
          content: SizedBox(
            width: 420,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                for (final profile in profiles)
                  CheckboxListTile(
                    value: selectedIds.contains(profile.id),
                    secondary: SizedBox(
                      width: 42,
                      height: 42,
                      child: PlayerAvatarFigure(
                        avatarId: profile.avatarId,
                        appearance: profile.avatar,
                        width: 42,
                        height: 42,
                        portrait: true,
                      ),
                    ),
                    title: Text(profile.displayName),
                    subtitle: Text('${profile.gamesPlayed} matches'),
                    onChanged: (checked) => setDialogState(() {
                      if (checked == true) {
                        selectedIds.add(profile.id);
                      } else {
                        selectedIds.remove(profile.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: selectedIds.isEmpty
                  ? null
                  : () => Navigator.pop(
                      dialogContext,
                      profiles
                          .where((profile) => selectedIds.contains(profile.id))
                          .map(
                            (profile) => PlayerConfiguration(
                              id: profile.id,
                              displayName: profile.displayName,
                            ),
                          )
                          .toList(growable: false),
                    ),
              child: const Text('SELECT PLAYERS'),
            ),
          ],
        ),
      ),
    );
    if (result != null) _controller.setPlayers(result);
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
      final issue = ActiveMatchController.validateConfiguration(
        configuration,
        pictureChallenges: _pictureChallenges,
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

enum _MatchChoice { quiz, wordPlay, guessing, mixed }

class _LobbySectionLabel extends StatelessWidget {
  const _LobbySectionLabel({
    required this.title,
    required this.detail,
    required this.compact,
  });

  final String title;
  final String detail;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: tokens.orange,
            fontSize: compact ? 10 : 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tokens.muted,
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchChoiceButton extends StatelessWidget {
  const _MatchChoiceButton({
    required this.choice,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _MatchChoice choice;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final (label, icon) = switch (choice) {
      _MatchChoice.quiz => ('QUIZ', Icons.quiz_rounded),
      _MatchChoice.wordPlay => ('WORD PLAY', Icons.abc_rounded),
      _MatchChoice.guessing => ('GUESSING GAMES', Icons.visibility_rounded),
      _MatchChoice.mixed => ('MIXED GAMES', Icons.shuffle_rounded),
    };
    return Material(
      color: selected ? const Color(0xB835281A) : const Color(0x77202A39),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 9),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? tokens.orange : Colors.white24,
                width: selected ? 3 : 1,
              ),
            ),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      tokens.orange.withValues(alpha: .22),
                      Colors.transparent,
                    ],
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: compact ? 15 : 19,
                color: selected ? tokens.orange : tokens.ink,
              ),
              SizedBox(width: compact ? 3 : 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 7.5 : 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: compact ? .1 : .6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedPlayer extends StatelessWidget {
  const _SelectedPlayer({
    required this.player,
    required this.profile,
    required this.compact,
    required this.onRemove,
  });

  final PlayerConfiguration player;
  final PlayerProfile? profile;
  final bool compact;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 48.0 : 72.0;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Tooltip(
      message: 'Remove ${player.displayName}',
      child: InkWell(
        onTap: onRemove,
        child: SizedBox(
          width: compact ? 58 : 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: profile == null
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xAA11243A),
                                border: Border.all(
                                  color: tokens.cyan.withValues(alpha: .7),
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: tokens.cyan,
                                size: size * .55,
                              ),
                            )
                          : PlayerAvatarFigure(
                              avatarId: profile!.avatarId,
                              appearance: profile!.avatar,
                              width: size,
                              height: size,
                              portrait: true,
                            ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.remove_circle,
                        size: compact ? 13 : 16,
                        color: tokens.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                player.displayName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 7 : 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundFormatPicker extends StatelessWidget {
  const _RoundFormatPicker({
    required this.selectedModules,
    required this.selectedFormatIds,
    required this.onToggle,
  });

  final Set<String> selectedModules;
  final Set<String> selectedFormatIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'ROUND FORMATS · ONE SHARED FORMAT FOR THE WHOLE ROUND',
          style: TextStyle(
            color: tokens.cyan,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 5,
          runSpacing: 3,
          children: <Widget>[
            for (final format in roundGameFormats.where(
              (item) => selectedModules.contains(item.moduleId),
            ))
              FilterChip(
                key: ValueKey<String>('round-format-${format.id}'),
                label: Text(format.title.toUpperCase()),
                selected: selectedFormatIds.contains(format.id),
                onSelected: format.available
                    ? (_) => onToggle(format.id)
                    : null,
                visualDensity: VisualDensity.compact,
                labelStyle: const TextStyle(fontSize: 9),
              ),
          ],
        ),
      ],
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

// ignore: unused_element
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

// ignore: unused_element
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
    required this.onCharacterPictureCategory,
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
  final ValueChanged<String> onCharacterPictureCategory;
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
          if (config.effectiveRoundFormatIds.contains('character_picture'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'PICTURE COLLECTION',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                  DropdownButton<String>(
                    key: const ValueKey<String>('character-picture-category'),
                    isExpanded: true,
                    value: config.characterPictureCategory,
                    items:
                        const <String>[
                              'All Categories',
                              'Marvel Characters',
                              'DC Characters',
                              'Anime Characters',
                              'Cartoon Characters',
                              'Disney Characters',
                              'DreamWorks Characters',
                              'Pixar Characters',
                              'Other Fictional Characters',
                              'Indian Actors and Actresses',
                              'Hollywood Actors',
                              'Footballers',
                              'Historical Presidents',
                              'Other People',
                            ]
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category.toUpperCase()),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) onCharacterPictureCategory(value);
                    },
                  ),
                  Text(
                    'Only matching, locally installed images are used. An empty category cannot start a Picture Mode match.',
                    style: TextStyle(color: tokens.muted, fontSize: 9),
                  ),
                ],
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
