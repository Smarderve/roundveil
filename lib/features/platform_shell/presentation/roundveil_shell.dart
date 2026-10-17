import 'package:flutter/material.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/player/player_avatar_catalog.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_draft.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/presentation/active_match_page.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/guess_character/presentation/character_picture_library_page.dart';
import 'package:roundveil/features/guess_country/presentation/player_avatar_figure.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';
import 'package:roundveil/features/platform_shell/presentation/create_player_dialog.dart';
import 'package:roundveil/features/platform_shell/presentation/cinematic_session_builder_page.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_quick_games_page.dart';
import 'package:roundveil/features/platform_shell/application/guessing_mode_capacity.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

enum _ShellDestination { home, create, quick, drafts, games, avatars, settings }

class RoundveilShell extends StatefulWidget {
  const RoundveilShell({
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.isDark,
    required this.locale,
    this.profileRepository,
    super.key,
  });

  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final bool isDark;
  final Locale locale;
  final PlayerProfileRepository? profileRepository;

  @override
  State<RoundveilShell> createState() => _RoundveilShellState();
}

class _RoundveilShellState extends State<RoundveilShell> {
  _ShellDestination _destination = _ShellDestination.home;
  final DraftRepository _drafts = LocalDraftRepository();
  late final PlayerProfileRepository _playerProfiles =
      widget.profileRepository ?? LocalPlayerProfileRepository();
  List<PlayerConfiguration> _lobbyPlayers = <PlayerConfiguration>[
    PlayerConfiguration.placeholder(1),
    PlayerConfiguration.placeholder(2),
  ];
  List<PlayerProfile> _profiles = const <PlayerProfile>[];
  String? _selectedProfileId;
  bool _profilesLoaded = false;

  @override
  void initState() {
    super.initState();
    _refreshProfiles();
  }

  Future<void> _refreshProfiles() async {
    try {
      final profiles = await _playerProfiles.ensureProfiles(_lobbyPlayers);
      if (mounted) {
        setState(() {
          _profiles = profiles;
          _selectedProfileId =
              profiles.any((profile) => profile.id == _selectedProfileId)
              ? _selectedProfileId
              : profiles.firstOrNull?.id;
          _profilesLoaded = true;
        });
      }
    } on Object {
      // Keep the playable lobby available if local profile storage fails.
      if (mounted) setState(() => _profilesLoaded = true);
    }
  }

  Future<void> _saveProfile(PlayerProfile profile) async {
    await _playerProfiles.updateProfile(profile);
    if (!mounted) return;
    setState(() {
      _profiles = <PlayerProfile>[
        for (final existing in _profiles)
          if (existing.id == profile.id) profile else existing,
      ];
      _selectedProfileId = profile.id;
      _lobbyPlayers = <PlayerConfiguration>[
        for (final player in _lobbyPlayers)
          player.id == profile.id
              ? PlayerConfiguration(
                  id: player.id,
                  displayName: profile.displayName,
                )
              : player,
      ];
    });
  }

  Future<PlayerProfile> _createProfile(
    String displayName,
    PlayerGender? gender,
    String avatarId,
  ) async {
    final created = await _playerProfiles.createProfile(
      displayName: displayName,
      gender: gender,
      avatarId: avatarId,
    );
    if (mounted) {
      setState(() {
        _profiles = <PlayerProfile>[..._profiles, created]
          ..sort((a, b) => a.id.compareTo(b.id));
        _selectedProfileId = created.id;
      });
    }
    return created;
  }

  Future<void> _deleteProfile(String playerId) async {
    await _playerProfiles.deleteProfile(playerId);
    if (!mounted) return;
    setState(() {
      _profiles = _profiles.where((profile) => profile.id != playerId).toList();
      if (_selectedProfileId == playerId) {
        _selectedProfileId = _profiles.firstOrNull?.id;
      }
      _lobbyPlayers = _lobbyPlayers
          .where((player) => player.id != playerId)
          .toList();
    });
  }

  void _useProfileInSquad(PlayerProfile profile) {
    if (_lobbyPlayers.any((player) => player.id == profile.id)) {
      setState(() => _selectedProfileId = profile.id);
      return;
    }
    if (_lobbyPlayers.length >= 12) return;
    setState(() {
      _selectedProfileId = profile.id;
      _lobbyPlayers = <PlayerConfiguration>[
        ..._lobbyPlayers,
        PlayerConfiguration(id: profile.id, displayName: profile.displayName),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (_destination) {
      _ShellDestination.home => V5LobbyPage(
        selectedProfileId: _selectedProfileId,
        onSelectedProfileChanged: (id) =>
            setState(() => _selectedProfileId = id),
        onCreateProfile: _createProfile,
        onCreate: (players) => setState(() {
          _lobbyPlayers = players;
          _destination = _ShellDestination.create;
        }),
        onQuick: () => _select(_ShellDestination.quick),
        onDrafts: () => _select(_ShellDestination.drafts),
        onGames: () => _select(_ShellDestination.games),
        onLaunchGame: _openConfiguredGame,
        onAvatars: () => _select(_ShellDestination.avatars),
        onProfileChanged: (profile) => _saveProfile(profile),
        players: _lobbyPlayers,
        profiles: _profiles,
        onPlayersChanged: (players) {
          setState(() => _lobbyPlayers = players);
          _refreshProfiles();
        },
      ),
      _ShellDestination.create => CinematicSessionBuilderPage(
        drafts: _drafts,
        profileRepository: _playerProfiles,
        initial: _lobbyPlayers.isEmpty
            ? null
            : SessionConfiguration(players: _lobbyPlayers),
        onBack: () => _select(_ShellDestination.home),
      ),
      _ShellDestination.quick => V5QuickGamesPage(
        drafts: _drafts,
        profileRepository: _playerProfiles,
        initialPlayers: _lobbyPlayers,
        onBack: () => _select(_ShellDestination.home),
      ),
      _ShellDestination.drafts => _DraftsPage(
        drafts: _drafts,
        onEdit: _editDraft,
        onOpenCountryPrototype: () => _openConfiguredGame('guessing_games'),
      ),
      _ShellDestination.games => _GameModesPage(
        onPlay: _openConfiguredGame,
        onPictureLibrary: _openPictureLibrary,
      ),
      _ShellDestination.settings => _SettingsPage(
        isDark: widget.isDark,
        locale: widget.locale,
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
      ),
      _ShellDestination.avatars => _AvatarWorkshopPage(
        profiles: _profiles,
        selectedProfileId: _selectedProfileId,
        onSelectedProfileChanged: (id) =>
            setState(() => _selectedProfileId = id),
        profilesLoaded: _profilesLoaded,
        onProfileChanged: _saveProfile,
        onCreateProfile: _createProfile,
        onDeleteProfile: _deleteProfile,
        onUsePlayer: _useProfileInSquad,
      ),
    };
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 230);

    final switchedPage = AnimatedSwitcher(
      duration: motion,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.025, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey<_ShellDestination>(_destination),
        child: page,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050D1C),
      body: SafeArea(
        child: _destination == _ShellDestination.home
            ? Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  switchedPage,
                  Align(
                    alignment: Alignment.topCenter,
                    child: _GameNavigationBar(
                      destination: _destination,
                      isDark: widget.isDark,
                      overlay: true,
                      onSelect: _select,
                      onThemeToggle: () =>
                          widget.onThemeChanged(!widget.isDark),
                    ),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  _GameNavigationBar(
                    destination: _destination,
                    isDark: widget.isDark,
                    onSelect: _select,
                    onThemeToggle: () => widget.onThemeChanged(!widget.isDark),
                  ),
                  Expanded(child: switchedPage),
                ],
              ),
      ),
    );
  }

  void _select(_ShellDestination destination) =>
      setState(() => _destination = destination);

  void _editDraft(SessionDraft draft) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _StandaloneBuilderRoute(
          drafts: _drafts,
          profileRepository: _playerProfiles,
          initial: draft.configuration,
          name: draft.name,
          templateId: draft.templateId,
          draftId: draft.id,
        ),
      ),
    );
  }

  Future<void> _openPictureLibrary() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const CharacterPictureLibraryPage(),
      ),
    );
  }

  Future<void> _openConfiguredGame(String gameId) async {
    var players = List<PlayerConfiguration>.of(_lobbyPlayers);
    if (players.isEmpty) {
      if (_profiles.isEmpty) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Choose saved players'),
            content: const Text(
              'Create at least one player profile before starting a game.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        _select(_ShellDestination.avatars);
        return;
      }
      final chosen = await _pickSavedPlayers();
      if (chosen == null || chosen.isEmpty || !mounted) return;
      players = chosen;
      setState(() => _lobbyPlayers = chosen);
    }

    String? selectedGuessingFormat;
    var pictureCategory = 'All Categories';
    var guessingRoundCount = 4;
    if (gameId == 'guessing_games') {
      final selection = await _pickGuessingMode(players);
      if (selection == null || !mounted) return;
      selectedGuessingFormat = selection.$1;
      pictureCategory = selection.$2;
      guessingRoundCount = selection.$3;
    }

    final (modules, formats) = switch (gameId) {
      'quiz' => (
        const <String>['quiz'],
        const <String>[
          'quiz_multiple_choice',
          'quiz_true_false',
          'quiz_fill_blank',
          'quiz_short_answer',
        ],
      ),
      'word_play' => (
        const <String>['word_play'],
        const <String>[
          'word_scramble',
          'word_missing_letters',
          'word_completion',
          'word_guess',
        ],
      ),
      _ => (
        <String>[
          switch (selectedGuessingFormat) {
            'character_picture' || 'character_name' => 'guess_character',
            _ => 'guess_country_flags',
          },
        ],
        <String>[selectedGuessingFormat!],
      ),
    };
    final configuration = SessionConfiguration(
      players: players,
      selectedModuleIds: modules,
      roundFormatIds: formats,
      roundFormatsExplicit: true,
      roundCount: guessingRoundCount,
      isMixed: false,
      characterPictureCategory: pictureCategory,
    );
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ActiveMatchPage(
          configuration: configuration,
          profileRepository: _playerProfiles,
        ),
      ),
    );
  }

  Future<(String, String, int)?> _pickGuessingMode(
    List<PlayerConfiguration> players,
  ) async {
    final pictures = await CharacterPictureRepository().loadPlayable();
    if (!mounted) return null;
    const rounds = 4;
    final required = players.length * rounds;
    final categories = <String>{
      'All Categories',
      ...characterPictureCategories,
      ...pictures.map((picture) => picture.category),
    }.toList(growable: false);
    var selectedCategory = 'All Categories';
    return showDialog<(String, String, int)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final pictureCount = pictures
              .where(
                (picture) =>
                    selectedCategory == 'All Categories' ||
                    picture.category == selectedCategory,
              )
              .length;
          final pictureRounds = pictureModeRoundCapacity(
            imageCount: pictureCount,
            playerCount: players.length,
          );
          final options = <(String, String, String, int, int, IconData)>[
            (
              'character_picture',
              'CHARACTER PICTURE',
              'Guess a character from a real image.',
              pictureRounds,
              pictureCount,
              Icons.image_search_rounded,
            ),
            (
              'character_name',
              'CHARACTER NAME',
              'Guess a character through verbal clues.',
              4,
              characterChallenges.length,
              Icons.record_voice_over_rounded,
            ),
            (
              'country_flag',
              'COUNTRY FLAG',
              'Recognize a real offline country flag.',
              4,
              countryChallenges.length,
              Icons.flag_rounded,
            ),
            (
              'country_name',
              'COUNTRY NAME',
              'Guess a country using geographic clues.',
              4,
              countryChallenges.length,
              Icons.public_rounded,
            ),
            (
              'object_picture',
              'OBJECT PICTURE',
              'Not available yet · object collection is not playable.',
              0,
              0,
              Icons.category_rounded,
            ),
          ];
          return AlertDialog(
            title: const Text('GUESSING GAMES'),
            content: SizedBox(
              width: (MediaQuery.sizeOf(context).width - 56).clamp(
                300.0,
                560.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text('Choose one game mode for this match.'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Picture category',
                        helperText: 'Applies to Character Picture only.',
                      ),
                      items: categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setDialogState(
                        () => selectedCategory = value ?? 'All Categories',
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final option in options)
                      Builder(
                        builder: (context) {
                          final available =
                              option.$1 != 'object_picture' &&
                              option.$4 > 0 &&
                              (option.$1 == 'character_picture' ||
                                  option.$5 >= required);
                          final status = option.$1 == 'object_picture'
                              ? 'Not implemented'
                              : option.$1 == 'character_picture'
                              ? '${option.$5} images · ${option.$4} ${option.$4 == 1 ? 'round' : 'rounds'} for ${players.length} players'
                              : '${option.$5} items · $rounds rounds for ${players.length} players';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            leading: Icon(
                              option.$6,
                              color: available
                                  ? const Color(0xFFFF9A3D)
                                  : Colors.white38,
                            ),
                            title: Text(
                              option.$2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text('${option.$3}  $status'),
                            enabled: available,
                            onTap: available
                                ? () => Navigator.pop(dialogContext, (
                                    option.$1,
                                    selectedCategory,
                                    option.$4,
                                  ))
                                : null,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<PlayerConfiguration>?> _pickSavedPlayers() => showDialog(
    context: context,
    builder: (dialogContext) {
      final selected = <String>{};
      return StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('SELECT PLAYERS'),
          content: SizedBox(
            width: 360,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                for (final profile in _profiles)
                  CheckboxListTile(
                    value: selected.contains(profile.id),
                    title: Text(profile.displayName),
                    onChanged: (value) => setDialogState(() {
                      if (value == true) {
                        selected.add(profile.id);
                      } else {
                        selected.remove(profile.id);
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
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(
                      dialogContext,
                      _profiles
                          .where((profile) => selected.contains(profile.id))
                          .map(
                            (profile) => PlayerConfiguration(
                              id: profile.id,
                              displayName: profile.displayName,
                            ),
                          )
                          .toList(),
                    ),
              child: const Text('START MATCH'),
            ),
          ],
        ),
      );
    },
  );
}

class _StandaloneBuilderRoute extends StatelessWidget {
  const _StandaloneBuilderRoute({
    required this.drafts,
    required this.profileRepository,
    required this.initial,
    required this.name,
    this.templateId,
    this.draftId,
  });

  final DraftRepository drafts;
  final PlayerProfileRepository profileRepository;
  final SessionConfiguration initial;
  final String name;
  final String? templateId;
  final String? draftId;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: CinematicSessionBuilderPage(
        drafts: drafts,
        profileRepository: profileRepository,
        initial: initial,
        initialName: name,
        templateId: templateId,
        draftId: draftId,
        onBack: () => Navigator.of(context).pop(),
      ),
    ),
  );
}

class _GameNavigationBar extends StatelessWidget {
  const _GameNavigationBar({
    required this.destination,
    required this.isDark,
    this.overlay = false,
    required this.onSelect,
    required this.onThemeToggle,
  });

  final _ShellDestination destination;
  final bool isDark;
  final bool overlay;
  final ValueChanged<_ShellDestination> onSelect;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    // Phone-landscape emulators commonly report a logical width near 900 dp;
    // reserve the local-play label for wider tablet/desktop headers.
    final compact = MediaQuery.sizeOf(context).width < 1050;
    final items = <(_ShellDestination, String, IconData)>[
      (_ShellDestination.home, 'HOME', Icons.home_rounded),
      (_ShellDestination.games, 'GAMES', Icons.sports_esports_rounded),
      (_ShellDestination.avatars, 'AVATARS', Icons.face_rounded),
      (_ShellDestination.drafts, 'DRAFTS', Icons.description_rounded),
      (_ShellDestination.settings, 'SETTINGS', Icons.settings_rounded),
    ];
    final railWidth = overlay
        ? (compact ? 116.0 : 164.0)
        : (compact ? 190.0 : 330.0);
    return Container(
      height: overlay ? (compact ? 42 : 56) : (compact ? 48 : 76),
      padding: EdgeInsets.symmetric(
        horizontal: overlay
            ? 4
            : compact
            ? 8
            : 24,
      ),
      decoration: BoxDecoration(
        color: overlay ? Colors.transparent : const Color(0xED06152B),
        border: overlay
            ? null
            : Border(
                bottom: BorderSide(color: tokens.cyan.withValues(alpha: .36)),
              ),
        boxShadow: overlay
            ? null
            : const <BoxShadow>[
                BoxShadow(
                  color: Color(0x88020A16),
                  blurRadius: 18,
                  offset: Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: railWidth,
            child: Image.asset(
              'assets/brand/roundveil_logo_lockup.webp',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              semanticLabel: 'ROUNDVEIL',
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: items
                      .map(
                        (item) => _TopNavItem(
                          label: item.$2,
                          icon: item.$3,
                          selected: item.$1 == destination,
                          compact: compact,
                          onTap: () => onSelect(item.$1),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          SizedBox(
            width: railWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (!compact && !overlay) ...<Widget>[
                  Icon(Icons.wifi_off_rounded, color: tokens.cyan, size: 17),
                  const SizedBox(width: 6),
                  Text(
                    'LOCAL PLAY',
                    style: TextStyle(
                      color: tokens.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
                IconButton(
                  onPressed: onThemeToggle,
                  tooltip: isDark
                      ? 'Switch to light theme'
                      : 'Switch to dark theme',
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  ),
                  color: tokens.ink,
                  visualDensity: overlay
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                  constraints: overlay
                      ? const BoxConstraints.tightFor(width: 30, height: 30)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavItem extends StatelessWidget {
  const _TopNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: AnimatedContainer(
            duration: duration,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 14,
              vertical: compact ? 7 : 12,
            ),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF5A3108) : Colors.transparent,
              border: Border.all(
                color: selected ? tokens.orange : Colors.transparent,
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: tokens.orange.withValues(alpha: .38),
                        blurRadius: 13,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: compact ? 15 : 18,
                  color: selected ? tokens.orange : tokens.ink,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : tokens.ink,
                    fontSize: compact ? 8 : 10,
                    letterSpacing: .7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.onCreate,
    required this.onQuick,
    required this.onDrafts,
    required this.onGames,
  });
  final VoidCallback onCreate;
  final VoidCallback onQuick;
  final VoidCallback onDrafts;
  final VoidCallback onGames;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cinematic = constraints.maxWidth >= 1120;
        final horizontalPadding = compact
            ? 20.0
            : cinematic
            ? 54.0
            : 32.0;
        final textWidth = compact
            ? 292.0
            : cinematic
            ? 520.0
            : (constraints.maxWidth - 80).clamp(320, 680).toDouble();
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            compact
                ? 20
                : cinematic
                ? 48
                : 24,
            compact ? 18 : 42,
            compact
                ? 20
                : cinematic
                ? 48
                : 24,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(minHeight: compact ? 450 : 475),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: tokens.cyan.withValues(alpha: .25),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          tokens.surface,
                          Color.lerp(tokens.surface, tokens.cyan, .08)!,
                          tokens.background,
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .16),
                          blurRadius: 36,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          right: -60,
                          top: -95,
                          child: Container(
                            width: compact ? 250 : 470,
                            height: compact ? 250 : 470,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: tokens.cyan.withValues(alpha: .11),
                                width: 1,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: tokens.cyan.withValues(alpha: .08),
                                  blurRadius: 100,
                                  spreadRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (cinematic)
                          Positioned(
                            right: 24,
                            bottom: 4,
                            child: Image.asset(
                              'assets/brand/roundveil_mascot_portrait.webp',
                              width: 420,
                              height: 425,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.all(horizontalPadding),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: textWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _Eyebrow(text: l10n.welcomeEyebrow),
                                const SizedBox(height: 22),
                                Text(
                                  l10n.welcomeTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        fontSize: compact
                                            ? 38
                                            : cinematic
                                            ? 66
                                            : 46,
                                      ),
                                ),
                                const SizedBox(height: 18),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 440,
                                  ),
                                  child: Text(
                                    l10n.welcomeBody,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontSize: 17, height: 1.55),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: <Widget>[
                                    FilledButton.icon(
                                      onPressed: onCreate,
                                      icon: const Icon(Icons.add_rounded),
                                      label: Text(l10n.createGame),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: onQuick,
                                      icon: const Icon(Icons.bolt_rounded),
                                      label: Text(l10n.quickGame),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(48, 52),
                                        foregroundColor: tokens.cyan,
                                        side: BorderSide(
                                          color: tokens.cyan.withValues(
                                            alpha: .65,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 19),
                                Text(
                                  l10n.rebuildStatus,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 2,
                    children: <Widget>[
                      Text(
                        l10n.gameModes,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: onGames,
                        child: Text(l10n.navLibrary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _GameStrip(onTap: onGames),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onDrafts,
                      icon: const Icon(Icons.bookmark_border_rounded),
                      label: Text(l10n.savedDrafts),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameStrip extends StatelessWidget {
  const _GameStrip({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: gameCatalog.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = gameCatalog[index];
          final l10n = AppLocalizations.of(context)!;
          return InkWell(
            onTap: onTap,
            child: Container(
              width: 194,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.surface.withValues(alpha: .8),
                border: Border.all(color: tokens.cyan.withValues(alpha: .16)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    _iconFor(game.id),
                    color: game.playable ? tokens.orange : tokens.cyan,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _gameTitle(l10n, game.titleKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game.playable
                              ? l10n.playablePrototype
                              : l10n.inFoundation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 22, height: 2, color: tokens.orange),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tokens.cyan,
              fontSize: 11,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickGamePage extends StatefulWidget {
  const _QuickGamePage({required this.drafts, required this.onBack});
  final DraftRepository drafts;
  final VoidCallback onBack;
  @override
  State<_QuickGamePage> createState() => _QuickGamePageState();
}

class _QuickGamePageState extends State<_QuickGamePage> {
  QuickGameTemplate? selected;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    if (selected case final template?) {
      return CinematicSessionBuilderPage(
        drafts: widget.drafts,
        initial: template.configuration,
        templateId: template.id,
        initialName: _gameTitle(l10n, template.titleKey),
        onBack: () => setState(() => selected = null),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.quickTemplates,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.templateDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 760
                      ? 3
                      : constraints.maxWidth > 480
                      ? 2
                      : 1;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: quickGameTemplates.map((template) {
                      final title = _gameTitle(l10n, template.titleKey);
                      final moduleNames = template.moduleIds
                          .map(
                            (id) => _gameTitle(
                              l10n,
                              gameCatalog
                                  .firstWhere((game) => game.id == id)
                                  .titleKey,
                            ),
                          )
                          .join(' · ');
                      return SizedBox(
                        width:
                            (constraints.maxWidth - (columns - 1) * 14) /
                            columns,
                        child: InkWell(
                          onTap: () => setState(() => selected = template),
                          child: Container(
                            height: 142,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: tokens.surface,
                              border: Border.all(
                                color: tokens.cyan.withValues(alpha: .22),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.bolt_rounded, color: tokens.orange),
                                const Spacer(),
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$moduleNames  ·  ${template.players} ${l10n.players.toLowerCase()}  ·  ${template.rounds} ${l10n.rounds.toLowerCase()}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarWorkshopPage extends StatefulWidget {
  const _AvatarWorkshopPage({
    required this.profiles,
    required this.selectedProfileId,
    required this.onSelectedProfileChanged,
    required this.profilesLoaded,
    required this.onProfileChanged,
    required this.onCreateProfile,
    required this.onDeleteProfile,
    required this.onUsePlayer,
  });
  final List<PlayerProfile> profiles;
  final String? selectedProfileId;
  final ValueChanged<String> onSelectedProfileChanged;
  final bool profilesLoaded;
  final ValueChanged<PlayerProfile> onProfileChanged;
  final Future<PlayerProfile> Function(String, PlayerGender?, String)
  onCreateProfile;
  final Future<void> Function(String) onDeleteProfile;
  final ValueChanged<PlayerProfile> onUsePlayer;

  @override
  State<_AvatarWorkshopPage> createState() => _AvatarWorkshopPageState();
}

class _AvatarWorkshopPageState extends State<_AvatarWorkshopPage> {
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 850 || size.height < 900;
    if (widget.profiles.isEmpty && !widget.profilesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.person_add_alt_1, size: 42),
            const SizedBox(height: 12),
            const Text('YOUR SQUAD IS EMPTY'),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => _createPlayer(context),
              icon: const Icon(Icons.add),
              label: const Text('CREATE PLAYER'),
            ),
          ],
        ),
      );
    }
    final selectedId =
        widget.profiles.any((profile) => profile.id == widget.selectedProfileId)
        ? widget.selectedProfileId!
        : widget.profiles.first.id;
    final profile = widget.profiles.firstWhere((item) => item.id == selectedId);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0C2033), Color(0xFF030812)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.face_retouching_natural, color: tokens.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SQUAD ARMORY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 17 : 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Create player',
                  onPressed: () => _createPlayer(context),
                  icon: const Icon(Icons.person_add_alt_1),
                ),
                if (compact)
                  const Tooltip(
                    message: 'Official art; personalized 3D viewer pending',
                    child: Icon(Icons.view_in_ar_outlined, size: 16),
                  )
                else
                  Text(
                    'OFFICIAL ART · PERSONALIZED 3D PENDING',
                    style: TextStyle(
                      color: tokens.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
              ],
            ),
            if (compact) ...<Widget>[
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      key: const ValueKey<String>('squad-player-selector'),
                      initialValue: selectedId,
                      decoration: const InputDecoration(
                        labelText: 'SQUAD PLAYER',
                        isDense: true,
                      ),
                      items: widget.profiles
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.displayName.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onSelectedProfileChanged(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile.displayName,
                      key: const ValueKey<String>('selected-player-callsign'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(profile.avatar.accentColor),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey<String>('edit-player-callsign'),
                    tooltip: 'Edit callsign',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _editCallsign(context, profile),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                  ),
                  IconButton(
                    tooltip: 'Delete ${profile.displayName}',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _confirmDelete(context, profile),
                    color: tokens.orange,
                    icon: const Icon(Icons.delete_outline, size: 19),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<PlayerGender?>(
                      key: ValueKey<String>('player-gender-${profile.id}'),
                      initialValue: profile.gender,
                      decoration: const InputDecoration(
                        labelText: 'OPTIONAL GENDER',
                        isDense: true,
                      ),
                      items: const <DropdownMenuItem<PlayerGender?>>[
                        DropdownMenuItem(
                          value: null,
                          child: Text('NOT SPECIFIED'),
                        ),
                        DropdownMenuItem(
                          value: PlayerGender.woman,
                          child: Text('WOMAN'),
                        ),
                        DropdownMenuItem(
                          value: PlayerGender.man,
                          child: Text('MAN'),
                        ),
                        DropdownMenuItem(
                          value: PlayerGender.nonBinary,
                          child: Text('NON-BINARY'),
                        ),
                      ],
                      onChanged: (gender) => widget.onProfileChanged(
                        profile.copyWith(gender: gender),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey<String>('use-player-in-squad'),
                    onPressed: () => widget.onUsePlayer(profile),
                    icon: const Icon(Icons.group_add_outlined, size: 18),
                    label: const Text('SQUAD'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${profile.wins} WINS  ·  ${profile.gamesPlayed} MATCHES  ·  ${profile.hintCredits} HINTS',
                  key: const ValueKey<String>('player-profile-stats'),
                  style: TextStyle(
                    color: tokens.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ] else ...<Widget>[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey<String>('squad-player-selector'),
                initialValue: selectedId,
                decoration: const InputDecoration(
                  labelText: 'SQUAD PLAYER',
                  isDense: true,
                ),
                items: widget.profiles
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.displayName.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) widget.onSelectedProfileChanged(value);
                },
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      profile.displayName,
                      key: const ValueKey<String>('selected-player-callsign'),
                      style: TextStyle(
                        color: Color(profile.avatar.accentColor),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey<String>('edit-player-callsign'),
                    onPressed: () => _editCallsign(context, profile),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('EDIT CALLSIGN'),
                  ),
                  IconButton(
                    tooltip: 'Delete ${profile.displayName}',
                    onPressed: () => _confirmDelete(context, profile),
                    color: tokens.orange,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<PlayerGender?>(
                      key: ValueKey<String>('player-gender-${profile.id}'),
                      initialValue: profile.gender,
                      decoration: const InputDecoration(
                        labelText: 'OPTIONAL GENDER',
                        isDense: true,
                      ),
                      items: const <DropdownMenuItem<PlayerGender?>>[
                        DropdownMenuItem(
                          value: null,
                          child: Text('NOT SPECIFIED'),
                        ),
                        DropdownMenuItem(
                          value: PlayerGender.woman,
                          child: Text('WOMAN'),
                        ),
                        DropdownMenuItem(
                          value: PlayerGender.man,
                          child: Text('MAN'),
                        ),
                        DropdownMenuItem(
                          value: PlayerGender.nonBinary,
                          child: Text('NON-BINARY'),
                        ),
                      ],
                      onChanged: (gender) => widget.onProfileChanged(
                        profile.copyWith(gender: gender),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    key: const ValueKey<String>('use-player-in-squad'),
                    onPressed: () => widget.onUsePlayer(profile),
                    icon: const Icon(Icons.group_add_outlined),
                    label: const Text('USE IN SQUAD'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '${profile.wins} WINS  ·  ${profile.gamesPlayed} MATCHES  ·  ${profile.hintCredits} HINTS',
                  key: const ValueKey<String>('player-profile-stats'),
                  style: TextStyle(
                    color: tokens.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stage = Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: <Color>[
                          Color(profile.avatar.accentColor)
                              .withValues(alpha: .3),
                          const Color(0xFF071321),
                        ],
                      ),
                      border: Border.all(
                        color: Color(profile.avatar.accentColor)
                            .withValues(alpha: .5),
                      ),
                    ),
                    child: PlayerAvatarFigure(
                      avatarId: profile.avatarId,
                      appearance: profile.avatar,
                      width: compact ? 105 : 220,
                      height: compact ? 145 : 300,
                    ),
                  );
                  if (size.height < 500) {
                    return Row(
                      children: <Widget>[
                        SizedBox(
                          width: constraints.maxWidth * .22,
                          child: stage,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _avatarGallery(profile)),
                      ],
                    );
                  }
                  if (compact) {
                    final stageHeight = constraints.maxHeight < 110
                        ? constraints.maxHeight * .35
                        : (constraints.maxHeight * .42).clamp(60.0, 132.0);
                    return Column(
                      children: <Widget>[
                        SizedBox(height: stageHeight, child: stage),
                        const SizedBox(height: 8),
                        Expanded(child: _avatarGallery(profile)),
                      ],
                    );
                  }
                  return Row(
                    children: <Widget>[
                      SizedBox(width: constraints.maxWidth * .34, child: stage),
                      const SizedBox(width: 20),
                      Expanded(child: _avatarGallery(profile)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlayer(BuildContext context) async {
    final draft = await showCreatePlayerDialog(
      context,
      existingProfiles: widget.profiles,
    );
    if (!mounted || draft == null) return;
    try {
      await widget.onCreateProfile(
        draft.displayName,
        draft.gender,
        draft.avatarId,
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save player: $error')));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PlayerProfile profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('DELETE PLAYER?'),
        content: Text(
          'Delete ${profile.displayName}, its appearance and saved statistics from this device?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.onDeleteProfile(profile.id);
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete player: $error')),
      );
    }
  }

  Future<void> _editCallsign(
    BuildContext context,
    PlayerProfile profile,
  ) async {
    var draftName = profile.displayName;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final keyboardOpen = MediaQuery.viewInsetsOf(dialogContext).bottom > 0;
        return AlertDialog(
          scrollable: true,
          title: const Text('EDIT PLAYER CALLSIGN'),
          content: SizedBox(
            height: keyboardOpen ? 60 : null,
            child: TextFormField(
              autofocus: true,
              initialValue: profile.displayName,
              maxLength: 24,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'PLAYER NAME',
                isDense: true,
                counterText: '',
              ),
              onChanged: (value) => draftName = value,
              onFieldSubmitted: (_) =>
                  Navigator.of(dialogContext).pop(draftName),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(draftName),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
    final trimmedName = name?.trim();
    if (trimmedName == null || trimmedName.isEmpty || !mounted) return;
    widget.onProfileChanged(profile.copyWith(displayName: trimmedName));
  }

  Widget _avatarGallery(PlayerProfile profile) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 850 || size.height < 900;
    final assignedAvatarIds = widget.profiles
        .where((item) => item.id != profile.id)
        .map((item) => item.avatarId)
        .toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'CHOOSE YOUR OPERATOR',
          style: TextStyle(
            color: Color(0xFF70D9FF),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemCount: PlayerAvatarCatalog.all.length,
            itemBuilder: (context, index) {
              final avatar = PlayerAvatarCatalog.all[index];
              final selected = profile.avatarId == avatar.id;
              final assigned = assignedAvatarIds.contains(avatar.id);
              return Semantics(
                button: true,
                selected: selected,
                label: '${avatar.name} avatar',
                child: InkWell(
                  key: ValueKey<String>('select-avatar-${avatar.id}'),
                  onTap: assigned
                      ? null
                      : () => widget.onProfileChanged(
                          profile.copyWith(avatarId: avatar.id),
                        ),
                  child: SizedBox(
                    width: compact ? 92 : 116,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF071321),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFF4A62C)
                              : const Color(0x4460D9FF),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.asset(
                            avatar.effectivePortraitAssetPath,
                            fit: BoxFit.cover,
                          ),
                          if (assigned)
                            const ColoredBox(
                              color: Color(0x99000000),
                              child: Center(
                                child: Text(
                                  'IN USE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              color: const Color(0xD9081424),
                              child: Text(
                                avatar.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .35,
                                ),
                              ),
                            ),
                          ),
                          if (selected)
                            const Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFF4A62C),
                                  size: 17,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (!compact) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            '${PlayerAvatarCatalog.all.length} ready characters · ${PlayerAvatarCatalog.all.length - 8} new originals',
            style: const TextStyle(color: Color(0xFF8B9BB1), fontSize: 10),
          ),
        ],
      ],
    );
  }
}

class _DraftsPage extends StatefulWidget {
  const _DraftsPage({
    required this.drafts,
    required this.onEdit,
    required this.onOpenCountryPrototype,
  });
  final DraftRepository drafts;
  final ValueChanged<SessionDraft> onEdit;
  final VoidCallback onOpenCountryPrototype;
  @override
  State<_DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<_DraftsPage> {
  late Future<List<SessionDraft>> _future;
  @override
  void initState() {
    super.initState();
    _future = widget.drafts.loadAll();
  }

  void _refresh() => setState(() => _future = widget.drafts.loadAll());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return FutureBuilder<List<SessionDraft>>(
      future: _future,
      builder: (context, snapshot) {
        final drafts = snapshot.data ?? const <SessionDraft>[];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.savedDrafts,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.localOffline,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (snapshot.connectionState != ConnectionState.done)
                    const Center(child: CircularProgressIndicator())
                  else if (drafts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        border: Border.all(
                          color: tokens.cyan.withValues(alpha: .2),
                        ),
                      ),
                      child: Text(l10n.noDrafts),
                    )
                  else
                    ...drafts.map(
                      (draft) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: tokens.surface,
                            border: Border(
                              left: BorderSide(color: tokens.orange, width: 3),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) => Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 10,
                              children: <Widget>[
                                SizedBox(
                                  width: constraints.maxWidth > 600
                                      ? constraints.maxWidth * .55
                                      : constraints.maxWidth,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        draft.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${draft.configuration.players.length} ${l10n.players.toLowerCase()} · ${draft.configuration.roundCount} ${l10n.rounds.toLowerCase()} · ${draft.configuration.selectedModuleIds.map((id) => _draftGameTitle(l10n, id)).join(' + ')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      if (draft.needsEditing) ...<Widget>[
                                        const SizedBox(height: 6),
                                        Text(
                                          l10n.draftNeedsEditing,
                                          style: TextStyle(
                                            color: Color(0xFFFFB84A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Wrap(
                                  spacing: 4,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () => widget.onEdit(draft),
                                      child: Text(l10n.editConfiguration),
                                    ),
                                    IconButton(
                                      tooltip: l10n.duplicate,
                                      onPressed: () async {
                                        await widget.drafts.save(
                                          SessionDraft(
                                            id: '${DateTime.now().microsecondsSinceEpoch}',
                                            name: '${draft.name} copy',
                                            configuration: draft.configuration,
                                            updatedAt: DateTime.now(),
                                            templateId: draft.templateId,
                                          ),
                                        );
                                        _refresh();
                                      },
                                      icon: const Icon(
                                        Icons.content_copy_rounded,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: l10n.delete,
                                      onPressed: () async {
                                        await widget.drafts.delete(draft.id);
                                        _refresh();
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                    ),
                                    if (draft
                                                .configuration
                                                .selectedModuleIds
                                                .length ==
                                            1 &&
                                        draft
                                                .configuration
                                                .selectedModuleIds
                                                .single ==
                                            'guess_country_flags')
                                      IconButton(
                                        tooltip: l10n.playablePrototype,
                                        onPressed:
                                            widget.onOpenCountryPrototype,
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
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
    );
  }
}

class _GameModesPage extends StatelessWidget {
  const _GameModesPage({required this.onPlay, required this.onPictureLibrary});

  final ValueChanged<String> onPlay;
  final VoidCallback onPictureLibrary;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    const games = <(String, String, IconData, Color)>[
      ('quiz', 'QUIZ', Icons.quiz_rounded, Color(0xFFFF9A3D)),
      ('word_play', 'WORD PLAY', Icons.abc_rounded, Color(0xFF5AD9FF)),
      (
        'guessing_games',
        'GUESSING GAMES',
        Icons.travel_explore_rounded,
        Color(0xFFFF9A3D),
      ),
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          children: <Widget>[
            const Text(
              'CHOOSE A GAME',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your choice starts the match directly with the players in your lobby.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 22),
            for (final game in games) ...<Widget>[
              Material(
                color: const Color(0xCC0A1A2E),
                child: InkWell(
                  onTap: () => onPlay(game.$1),
                  child: SizedBox(
                    height: 78,
                    child: Row(
                      children: <Widget>[
                        Container(width: 5, color: game.$4),
                        const SizedBox(width: 18),
                        Icon(game.$3, color: game.$4, size: 29),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            game.$2,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const Icon(Icons.play_arrow_rounded),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onPictureLibrary,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('MANAGE CHARACTER PICTURE COLLECTION'),
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.cyan,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.isDark,
    required this.locale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });
  final bool isDark;
  final Locale locale;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  static const locales = <(String, Locale)>[
    ('English', Locale('en')),
    ('Kiswahili', Locale('sw')),
    ('العربية', Locale('ar')),
    ('हिन्दी', Locale('hi')),
    ('简体中文', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')),
    ('한국어', Locale('ko')),
    ('Português', Locale('pt')),
    ('Español', Locale('es')),
    ('Français', Locale('fr')),
    ('日本語', Locale('ja')),
    ('اردو', Locale('ur')),
    ('Türkçe', Locale('tr')),
  ];
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.navSettings,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                color: tokens.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.appearance,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isDark ? l10n.themeDark : l10n.themeLight),
                      value: isDark,
                      onChanged: onThemeChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                color: tokens.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.language,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      l10n.languageNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Locale>(
                      initialValue: locale,
                      isExpanded: true,
                      items: locales
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.$2,
                              child: Text(entry.$1),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onLocaleChanged(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.localOffline,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _gameTitle(AppLocalizations l10n, String key) => switch (key) {
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

String _draftGameTitle(AppLocalizations l10n, String id) {
  for (final game in gameCatalog) {
    if (game.id == id) return _gameTitle(l10n, game.titleKey);
  }
  return 'Discontinued game';
}

IconData _iconFor(String id) => switch (id) {
  'quiz' => Icons.quiz_outlined,
  'word_play' => Icons.text_fields_rounded,
  'guess_character' => Icons.person_search_outlined,
  'guess_country_flags' => Icons.flag_outlined,
  _ => Icons.sports_esports_outlined,
};
