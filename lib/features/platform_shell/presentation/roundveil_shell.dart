import 'package:flutter/material.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_draft.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/presentation/active_match_page.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';
import 'package:roundveil/features/platform_shell/presentation/cinematic_session_builder_page.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_quick_games_page.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

enum _ShellDestination { home, create, quick, drafts, games, avatars, settings }

class RoundveilShell extends StatefulWidget {
  const RoundveilShell({
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.isDark,
    required this.locale,
    super.key,
  });

  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final bool isDark;
  final Locale locale;

  @override
  State<RoundveilShell> createState() => _RoundveilShellState();
}

class _RoundveilShellState extends State<RoundveilShell> {
  _ShellDestination _destination = _ShellDestination.home;
  final DraftRepository _drafts = LocalDraftRepository();
  List<PlayerConfiguration> _lobbyPlayers = const <PlayerConfiguration>[];

  @override
  Widget build(BuildContext context) {
    final page = switch (_destination) {
      _ShellDestination.home => V5LobbyPage(
        onCreate: (players) => setState(() {
          _lobbyPlayers = players;
          _destination = _ShellDestination.create;
        }),
        onQuick: () => _select(_ShellDestination.quick),
        onDrafts: () => _select(_ShellDestination.drafts),
        onGames: () => _select(_ShellDestination.games),
        onAvatars: () => _select(_ShellDestination.avatars),
        players: _lobbyPlayers,
        onPlayersChanged: (players) => setState(() => _lobbyPlayers = players),
      ),
      _ShellDestination.create => CinematicSessionBuilderPage(
        drafts: _drafts,
        initial: _lobbyPlayers.isEmpty
            ? null
            : SessionConfiguration(players: _lobbyPlayers),
        onBack: () => _select(_ShellDestination.home),
      ),
      _ShellDestination.quick => V5QuickGamesPage(
        drafts: _drafts,
        onBack: () => _select(_ShellDestination.home),
      ),
      _ShellDestination.drafts => _DraftsPage(
        drafts: _drafts,
        onEdit: _editDraft,
        onOpenCountryPrototype: _openCountryPrototype,
      ),
      _ShellDestination.games => _GameModesPage(
        onPlayCountry: _openCountryPrototype,
        onCreate: () => _select(_ShellDestination.create),
      ),
      _ShellDestination.settings => _SettingsPage(
        isDark: widget.isDark,
        locale: widget.locale,
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
      ),
      _ShellDestination.avatars => const _AvatarWorkshopPage(),
    };
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 230);

    return Scaffold(
      backgroundColor: const Color(0xFF050D1C),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _GameNavigationBar(
              destination: _destination,
              isDark: widget.isDark,
              onSelect: _select,
              onThemeToggle: () => widget.onThemeChanged(!widget.isDark),
            ),
            Expanded(
              child: AnimatedSwitcher(
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
              ),
            ),
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
          initial: draft.configuration,
          name: draft.name,
          templateId: draft.templateId,
          draftId: draft.id,
        ),
      ),
    );
  }

  void _openCountryPrototype() {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
      ],
      selectedModuleIds: const <String>['guess_country_flags'],
      roundCount: 3,
    );
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ActiveMatchPage(configuration: configuration),
      ),
    );
  }
}

class _StandaloneBuilderRoute extends StatelessWidget {
  const _StandaloneBuilderRoute({
    required this.drafts,
    required this.initial,
    required this.name,
    this.templateId,
    this.draftId,
  });

  final DraftRepository drafts;
  final SessionConfiguration initial;
  final String name;
  final String? templateId;
  final String? draftId;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: CinematicSessionBuilderPage(
        drafts: drafts,
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
    required this.onSelect,
    required this.onThemeToggle,
  });

  final _ShellDestination destination;
  final bool isDark;
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
    return Container(
      height: compact ? 48 : 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 24),
      decoration: BoxDecoration(
        color: const Color(0xED06152B),
        border: Border(
          bottom: BorderSide(color: tokens.cyan.withValues(alpha: .36)),
        ),
        boxShadow: const <BoxShadow>[
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
            width: compact ? 132 : 250,
            child: Image.asset(
              'assets/brand/roundveil_logo_lockup.webp',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
          if (!compact) ...<Widget>[
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
            tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            color: tokens.ink,
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

class _AvatarWorkshopPage extends StatelessWidget {
  const _AvatarWorkshopPage();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF07172D), Color(0xFF030812)],
              ),
            ),
          ),
          Positioned(
            right: constraints.maxWidth * .08,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: .55,
              child: Image.asset(
                'assets/brand/roundveil_mascot_portrait.webp',
                width: constraints.maxWidth * .38,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * .62),
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth < 800 ? 24 : 64),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'AVATAR WORKSHOP',
                      style: TextStyle(
                        color: tokens.cyan,
                        letterSpacing: 2,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'The character renderer is still being verified.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This is approved 2D ROUNDVEIL artwork for temporary presentation, not a rendered or customizable 3D avatar. Avatar editing will unlock after real Windows and Android rendering passes.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: tokens.orange, width: 3),
                        ),
                        color: tokens.surface,
                      ),
                      child: const Text('3D AVATAR CUSTOMIZATION · PENDING'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
  const _GameModesPage({required this.onPlayCountry, required this.onCreate});
  final VoidCallback onPlayCountry;
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.gameModes,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.rebuildStatus,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 780
                      ? 3
                      : constraints.maxWidth > 500
                      ? 2
                      : 1;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: gameCatalog
                        .map(
                          (game) => SizedBox(
                            width:
                                (constraints.maxWidth - (columns - 1) * 14) /
                                columns,
                            child: Container(
                              height: 200,
                              padding: const EdgeInsets.all(19),
                              decoration: BoxDecoration(
                                color: tokens.surface,
                                border: Border.all(
                                  color: game.playable
                                      ? tokens.orange.withValues(alpha: .6)
                                      : tokens.cyan.withValues(alpha: .18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        _iconFor(game.id),
                                        color: game.playable
                                            ? tokens.orange
                                            : tokens.cyan,
                                      ),
                                      const Spacer(),
                                      Text(
                                        game.playable
                                            ? l10n.playablePrototype
                                            : l10n.inFoundation,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _gameTitle(l10n, game.titleKey),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      game.playable
                                          ? l10n.playablePrototype
                                          : l10n.inFoundation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                  if (game.id == 'guess_country_flags')
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: onPlayCountry,
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                        ),
                                        label: Text(l10n.playablePrototype),
                                      ),
                                    )
                                  else
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: onCreate,
                                        child: Text(l10n.createGame),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
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
