import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/guess_country/presentation/player_avatar_figure.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

/// Interactive Version 5 lobby composition. The scene plate is artwork only;
/// navigation, squad editing, profile selection and launch actions stay real
/// Flutter controls above it.
class V5LobbyPage extends StatefulWidget {
  const V5LobbyPage({
    required this.players,
    required this.profiles,
    required this.onPlayersChanged,
    required this.onCreate,
    required this.onQuick,
    required this.onDrafts,
    required this.onGames,
    required this.onAvatars,
    super.key,
  });

  final List<PlayerConfiguration> players;
  final List<PlayerProfile> profiles;
  final ValueChanged<List<PlayerConfiguration>> onPlayersChanged;
  final ValueChanged<List<PlayerConfiguration>> onCreate;
  final VoidCallback onQuick;
  final VoidCallback onDrafts;
  final VoidCallback onGames;
  final VoidCallback onAvatars;

  @override
  State<V5LobbyPage> createState() => _V5LobbyPageState();
}

class _V5LobbyPageState extends State<V5LobbyPage> {
  String? _selectedProfileId;

  PlayerProfile? get _selectedProfile =>
      widget.profiles
          .where((profile) => profile.id == _selectedProfileId)
          .firstOrNull ??
      widget.profiles.firstOrNull;

  void _stepProfile(int direction) {
    final profile = _selectedProfile;
    if (profile == null || widget.profiles.length < 2) return;
    final current = widget.profiles.indexWhere((item) => item.id == profile.id);
    final next =
        (current + direction + widget.profiles.length) % widget.profiles.length;
    setState(() => _selectedProfileId = widget.profiles[next].id);
  }

  void _addPlayer() {
    if (widget.players.length >= 12) return;
    final usedNumbers = widget.players
        .map((player) => int.tryParse(player.id.replaceFirst('player-', '')))
        .whereType<int>()
        .toSet();
    var nextNumber = 1;
    while (usedNumbers.contains(nextNumber)) {
      nextNumber++;
    }
    widget.onPlayersChanged(<PlayerConfiguration>[
      ...widget.players,
      PlayerConfiguration.placeholder(nextNumber),
    ]);
  }

  void _removePlayer(String playerId) => widget.onPlayersChanged(
    widget.players.where((player) => player.id != playerId).toList(),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 1050 || size.height < 570;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final activeProfile = _selectedProfile;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = compact ? 150.0 : 218.0;
        final right = compact
            ? (constraints.maxWidth * .34).clamp(260.0, 360.0)
            : (constraints.maxWidth * .27).clamp(350.0, 450.0);
        final bottom = compact ? 62.0 : 96.0;
        final contentTop = compact ? 47.0 : 63.0;
        final centerWidth = constraints.maxWidth - side - right - 18;
        final availableHeroHeight =
            constraints.maxHeight - contentTop - bottom - 12;
        final heroWidth = math.min(
          centerWidth * .68,
          availableHeroHeight * .66,
        );
        final heroHeight = math.min(availableHeroHeight, heroWidth * 220 / 150);
        final heroLeft = side + (centerWidth - heroWidth) * .29;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const V5SceneArt(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x10020A16),
                    Color(0x06020A16),
                    Color(0xB8020A16),
                  ],
                ),
              ),
            ),
            if (activeProfile != null)
              Positioned(
                left: heroLeft,
                top: contentTop + 5,
                width: heroWidth,
                height: heroHeight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: PlayerAvatarFigure(
                    key: ValueKey<String>('lobby-hero-${activeProfile.id}'),
                    appearance: activeProfile.avatar,
                    width: heroWidth,
                    height: heroHeight,
                  ),
                ),
              ),
            Positioned(
              left: compact ? 7 : 22,
              top: contentTop,
              bottom: bottom + (compact ? 9 : 16),
              width: side,
              child: _SquadDock(
                players: widget.players,
                profiles: widget.profiles,
                compact: compact,
                onAdd: _addPlayer,
                onRemove: _removePlayer,
                onPortraits: widget.onAvatars,
              ),
            ),
            Positioned(
              right: compact ? 8 : 25,
              top: contentTop,
              bottom: bottom + (compact ? 9 : 16),
              width: right,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: compact ? 43 : 58,
                    child: _ProfileSelectionRail(
                      profile: activeProfile,
                      profileCount: widget.profiles.length,
                      onStep: _stepProfile,
                    ),
                  ),
                  SizedBox(height: compact ? 5 : 10),
                  SizedBox(
                    height: compact ? 58 : 102,
                    child: _CommandCard(
                      title: AppLocalizations.of(context)!.quickGame,
                      subtitle: 'FIND A MATCH AND PLAY INSTANTLY',
                      icon: Icons.bolt_rounded,
                      color: tokens.orange,
                      onTap: widget.onQuick,
                      compact: compact,
                    ),
                  ),
                  SizedBox(height: compact ? 5 : 9),
                  SizedBox(
                    height: compact ? 52 : 88,
                    child: _CommandCard(
                      title: AppLocalizations.of(context)!.createGame,
                      subtitle: 'SET RULES AND INVITE PLAYERS',
                      icon: Icons.groups_rounded,
                      color: tokens.cyan,
                      onTap: () => widget.onCreate(widget.players),
                      compact: compact,
                    ),
                  ),
                  SizedBox(height: compact ? 5 : 9),
                  SizedBox(
                    height: compact ? 30 : 42,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _FeatureButton(
                            icon: Icons.description_outlined,
                            label: AppLocalizations.of(context)!.savedDrafts,
                            onTap: widget.onDrafts,
                          ),
                        ),
                        SizedBox(width: compact ? 5 : 8),
                        Expanded(
                          child: _FeatureButton(
                            icon: Icons.face_rounded,
                            label: 'AVATARS',
                            onTap: widget.onAvatars,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: compact ? 7 : 22,
              right: compact ? 8 : 25,
              bottom: compact ? 5 : 12,
              height: bottom,
              child: _GameModeRail(compact: compact, onTap: widget.onGames),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileSelectionRail extends StatelessWidget {
  const _ProfileSelectionRail({
    required this.profile,
    required this.profileCount,
    required this.onStep,
  });
  final PlayerProfile? profile;
  final int profileCount;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) return const SizedBox.shrink();
    final compact = MediaQuery.sizeOf(context).width < 1050;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xC6071423),
        border: Border(
          bottom: BorderSide(color: tokens.cyan.withValues(alpha: .62)),
          left: BorderSide(color: Color(profile.avatar.accentColor), width: 2),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: compact ? 38 : 48,
            height: compact ? 38 : 48,
            child: PlayerAvatarFigure(
              key: ValueKey<String>('home-player-portrait-${profile.id}'),
              appearance: profile.avatar,
              width: compact ? 38 : 48,
              height: compact ? 38 : 48,
              portrait: true,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Column(
                key: ValueKey<String>(profile.id),
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profile.displayName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(profile.avatar.accentColor),
                      fontSize: compact ? 8 : 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .55,
                    ),
                  ),
                  Text(
                    '${profile.wins} WINS  ·  ${profile.gamesPlayed} MATCHES  ·  ${profile.hintCredits} HINTS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 5.6 : 7.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Previous player',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 22, height: 30),
            padding: EdgeInsets.zero,
            onPressed: profileCount < 2 ? null : () => onStep(-1),
            icon: const Icon(Icons.chevron_left_rounded, size: 19),
          ),
          IconButton(
            tooltip: 'Next player',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 22, height: 30),
            padding: EdgeInsets.zero,
            onPressed: profileCount < 2 ? null : () => onStep(1),
            icon: const Icon(Icons.chevron_right_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}

class V5SceneArt extends StatelessWidget {
  const V5SceneArt({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/v5/v5_tech_arena_environment.png',
    fit: BoxFit.cover,
    alignment: Alignment.center,
    filterQuality: FilterQuality.high,
    semanticLabel: 'Cinematic Version 5 ROUNDVEIL arena environment',
  );
}

class _CommandCard extends StatefulWidget {
  const _CommandCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.compact,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<_CommandCard> createState() => _CommandCardState();
}

class _CommandCardState extends State<_CommandCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() {
      _hovered = false;
      _pressed = false;
    }),
    child: GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed
            ? .985
            : _hovered
            ? 1.012
            : 1,
        duration: const Duration(milliseconds: 180),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: ClipPath(
              clipper: const _AngularClipper(),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          const Color(0xF70A1830),
                          const Color(0xC70A1830),
                          widget.color.withValues(alpha: .25),
                        ],
                        stops: const <double>[0, .58, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    right: widget.compact ? 18 : 40,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        widget.icon,
                        size: widget.compact ? 44 : 76,
                        color: widget.color.withValues(alpha: .22),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 5,
                    child: ColoredBox(color: widget.color),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.compact ? 12 : 20,
                      vertical: widget.compact ? 6 : 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: widget.compact ? 6.2 : 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: widget.compact ? 4 : 8),
                        Text(
                          widget.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.compact ? 13 : 22,
                            height: .95,
                            letterSpacing: .4,
                            fontWeight: FontWeight.w900,
                            shadows: const <Shadow>[
                              Shadow(color: Colors.black87, blurRadius: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: widget.compact ? 7 : 12,
                    bottom: widget.compact ? 6 : 10,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: widget.compact ? 15 : 21,
                      color: widget.color,
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _hovered ? .28 : .08,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: widget.color, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AngularClipper extends CustomClipper<Path> {
  const _AngularClipper();
  @override
  Path getClip(Size size) => Path()
    ..moveTo(16, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - 16)
    ..lineTo(size.width - 16, size.height)
    ..lineTo(0, size.height)
    ..lineTo(0, 16)
    ..close();
  @override
  bool shouldReclip(_AngularClipper oldClipper) => false;
}

class _SquadDock extends StatelessWidget {
  const _SquadDock({
    required this.players,
    required this.profiles,
    required this.compact,
    required this.onAdd,
    required this.onRemove,
    required this.onPortraits,
  });
  final List<PlayerConfiguration> players;
  final List<PlayerProfile> profiles;
  final bool compact;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onPortraits;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.groups_rounded,
              color: tokens.orange,
              size: compact ? 15 : 20,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'SQUAD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 9 : 13,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                  shadows: const <Shadow>[
                    Shadow(color: Colors.black, blurRadius: 8),
                  ],
                ),
              ),
            ),
            Text(
              '${players.length}/12',
              style: TextStyle(color: tokens.cyan, fontSize: compact ? 8 : 10),
            ),
          ],
        ),
        SizedBox(height: compact ? 8 : 15),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              for (var index = 0; index < players.length; index++)
                _PlayerSlot(
                  number: index + 1,
                  name: players[index].displayName,
                  playerId: players[index].id,
                  filled: true,
                  compact: compact,
                  appearance:
                      profiles
                          .where((profile) => profile.id == players[index].id)
                          .firstOrNull
                          ?.avatar ??
                      PlayerAvatarAppearance.forPlayer(index + 1),
                  onTap: () => onRemove(players[index].id),
                ),
              if (players.length < 12)
                _PlayerSlot(
                  number: players.length + 1,
                  name: 'ADD PLAYER',
                  playerId: null,
                  filled: false,
                  compact: compact,
                  appearance: null,
                  onTap: onAdd,
                ),
            ],
          ),
        ),
        if (players.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => onRemove(players.last.id),
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 14),
              label: const Text('REMOVE LAST'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        TextButton.icon(
          onPressed: onPortraits,
          icon: Icon(Icons.palette_outlined, size: compact ? 14 : 17),
          label: const Text('EDIT LOOK'),
          style: TextButton.styleFrom(
            foregroundColor: tokens.cyan,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            textStyle: TextStyle(
              fontSize: compact ? 8 : 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerSlot extends StatelessWidget {
  const _PlayerSlot({
    required this.number,
    required this.name,
    required this.playerId,
    required this.filled,
    required this.compact,
    required this.appearance,
    required this.onTap,
  });
  final int number;
  final String name;
  final String? playerId;
  final bool filled;
  final bool compact;
  final PlayerAvatarAppearance? appearance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final portraitSize = compact ? 39.0 : 54.0;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 5 : 8),
      child: Material(
        color: const Color(0x78071325),
        child: InkWell(
          onTap: filled ? null : onTap,
          child: SizedBox(
            height: compact ? 45 : 62,
            child: Row(
              children: <Widget>[
                if (filled && appearance != null)
                  SizedBox(
                    width: portraitSize,
                    height: portraitSize,
                    child: PlayerAvatarFigure(
                      key: ValueKey<String>('squad-portrait-$playerId'),
                      appearance: appearance!,
                      width: portraitSize,
                      height: portraitSize,
                      portrait: true,
                    ),
                  )
                else
                  SizedBox(
                    width: portraitSize,
                    height: portraitSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x44041120),
                        border: Border.all(
                          color: tokens.cyan.withValues(alpha: .6),
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: tokens.cyan,
                        size: compact ? 19 : 25,
                      ),
                    ),
                  ),
                SizedBox(width: compact ? 5 : 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        filled
                            ? name.toUpperCase()
                            : 'PLAYER ${number.toString().padLeft(2, '0')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 7 : 9,
                          letterSpacing: .35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (filled)
                        Text(
                          'READY',
                          style: TextStyle(
                            color: tokens.cyan,
                            fontSize: compact ? 6 : 7,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
                if (filled)
                  IconButton(
                    tooltip: 'Remove $name',
                    onPressed: onTap,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 34,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: compact ? 14 : 16,
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

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xA8071428),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          children: <Widget>[
            Icon(icon, color: const Color(0xFF68D8FF), size: 15),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  letterSpacing: .4,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GameModeRail extends StatelessWidget {
  const _GameModeRail({required this.compact, required this.onTap});
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: <Widget>[
        for (var index = 0; index < gameCatalog.length; index++) ...<Widget>[
          if (index > 0) SizedBox(width: compact ? 4 : 8),
          Expanded(
            child: Material(
              color: const Color(0xBC071426),
              child: InkWell(
                onTap: onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _GameModeArtwork(gameId: gameCatalog[index].id),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0x12030B18), Color(0xF0030B18)],
                          stops: <double>[.1, 1],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 5 : 8,
                          2,
                          3,
                          compact ? 4 : 7,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _gameTitle(
                                l10n,
                                gameCatalog[index].titleKey,
                              ).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 6.4 : 9,
                                height: 1,
                                letterSpacing: .15,
                                fontWeight: FontWeight.w900,
                                shadows: const <Shadow>[
                                  Shadow(color: Colors.black, blurRadius: 7),
                                ],
                              ),
                            ),
                            if (!compact)
                              Text(
                                _gameSubtitle(gameCatalog[index].id),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 6.2,
                                  letterSpacing: .25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 2,
                      child: ColoredBox(
                        color: gameCatalog[index].playable
                            ? tokens.orange
                            : tokens.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _gameSubtitle(String id) => switch (id) {
  'quiz' => 'TEST YOUR KNOWLEDGE',
  'word_play' => 'BUILD WORDS, SCORE BIG',
  'guess_character' => 'SPOT THE RIGHT HERO',
  'guess_country_flags' => 'EXPLORE THE WORLD',
  _ => '',
};

class _GameModeArtwork extends StatelessWidget {
  const _GameModeArtwork({required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/game_modes/$gameId.jpg',
    fit: BoxFit.cover,
    filterQuality: FilterQuality.high,
    semanticLabel: '$gameId original ROUNDVEIL game-mode artwork',
  );
}

String _gameTitle(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quiz,
  'wordPlay' => l10n.wordPlay,
  'guessCharacter' => l10n.guessCharacter,
  'guessCountry' => l10n.guessCountry,
  _ => key,
};
