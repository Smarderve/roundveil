import 'package:flutter/material.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

class V5LobbyPage extends StatelessWidget {
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

  void _addPlayer() {
    if (players.length >= 12) return;
    final usedNumbers = players
        .map((player) => int.tryParse(player.id.replaceFirst('player-', '')))
        .whereType<int>()
        .toSet();
    var nextNumber = 1;
    while (usedNumbers.contains(nextNumber)) {
      nextNumber++;
    }
    onPlayersChanged(<PlayerConfiguration>[
      ...players,
      PlayerConfiguration.placeholder(nextNumber),
    ]);
  }

  void _removePlayer(String playerId) => onPlayersChanged(
    players.where((player) => player.id != playerId).toList(),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 1050 || size.height < 570;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = compact ? 150.0 : 218.0;
        final right = compact
            ? (constraints.maxWidth * .34).clamp(260.0, 360.0)
            : (constraints.maxWidth * .27).clamp(350.0, 450.0);
        final bottom = compact ? 62.0 : 96.0;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const V5SceneArt(animate: true),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x18020A16),
                    Color(0x12020A16),
                    Color(0xBF020A16),
                  ],
                ),
              ),
            ),
            Positioned(
              left: side + 12,
              right: right + 12,
              top: compact ? 5 : 12,
              height: compact ? 42 : 58,
              child: _ProfileSelectionRail(profiles: profiles),
            ),
            Positioned(
              left: compact ? 7 : 22,
              top: compact ? 8 : 18,
              bottom: bottom + (compact ? 9 : 16),
              width: side,
              child: _SquadDock(
                players: players,
                profiles: profiles,
                compact: compact,
                onAdd: _addPlayer,
                onRemove: _removePlayer,
                onPortraits: onAvatars,
              ),
            ),
            Positioned(
              right: compact ? 8 : 25,
              top: compact ? 8 : 19,
              bottom: bottom + (compact ? 9 : 16),
              width: right,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: _CommandCard(
                      title: AppLocalizations.of(context)!.createGame,
                      subtitle: 'BUILD YOUR MATCH',
                      icon: Icons.sports_esports_rounded,
                      color: tokens.orange,
                      onTap: () => onCreate(players),
                      compact: compact,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 11),
                  Expanded(
                    child: _CommandCard(
                      title: AppLocalizations.of(context)!.quickGame,
                      subtitle: 'JUMP STRAIGHT IN',
                      icon: Icons.bolt_rounded,
                      color: tokens.cyan,
                      onTap: onQuick,
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
                            onTap: onDrafts,
                          ),
                        ),
                        SizedBox(width: compact ? 5 : 8),
                        Expanded(
                          child: _FeatureButton(
                            icon: Icons.face_rounded,
                            label: 'AVATARS',
                            onTap: onAvatars,
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
              child: _GameModeRail(
                compact: compact,
                onTap: onGames,
                onCreate: () => onCreate(players),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileSelectionRail extends StatefulWidget {
  const _ProfileSelectionRail({required this.profiles});

  final List<PlayerProfile> profiles;

  @override
  State<_ProfileSelectionRail> createState() => _ProfileSelectionRailState();
}

class _ProfileSelectionRailState extends State<_ProfileSelectionRail> {
  String? _selectedId;

  PlayerProfile? get _selected {
    if (widget.profiles.isEmpty) return null;
    return widget.profiles
            .where((profile) => profile.id == _selectedId)
            .firstOrNull ??
        widget.profiles.first;
  }

  void _step(int amount) {
    final current = _selected;
    if (current == null || widget.profiles.length < 2) return;
    final currentIndex = widget.profiles.indexWhere(
      (profile) => profile.id == current.id,
    );
    final nextIndex =
        (currentIndex + amount + widget.profiles.length) %
        widget.profiles.length;
    setState(() => _selectedId = widget.profiles[nextIndex].id);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _selected;
    if (profile == null) return const SizedBox.shrink();
    final compact = MediaQuery.sizeOf(context).width < 1050;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final details = <String>[
      '${profile.wins} WINS',
      '${profile.gamesPlayed} MATCHES',
      '${profile.hintCredits} HINTS',
      if (profile.gender case final gender?) gender.name.toUpperCase(),
    ].join('  ·  ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB8051020),
        border: Border(
          bottom: BorderSide(color: tokens.cyan.withValues(alpha: .7)),
          left: BorderSide(color: Color(profile.avatar.accentColor), width: 2),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: compact ? 36 : 46,
            height: compact ? 36 : 46,
            child: Image.asset(
              'assets/brand/roundveil_mascot_portrait.webp',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Official ROUNDVEIL player portrait',
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
                      fontSize: compact ? 9 : 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 6 : 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Previous player',
            visualDensity: VisualDensity.compact,
            onPressed: widget.profiles.length < 2 ? null : () => _step(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            tooltip: 'Next player',
            visualDensity: VisualDensity.compact,
            onPressed: widget.profiles.length < 2 ? null : () => _step(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class V5SceneArt extends StatelessWidget {
  const V5SceneArt({this.animate = false, super.key});

  // Kept as a compatible parameter for existing callers; the approved key art
  // is intentionally still, avoiding motion on a flattened illustration.
  final bool animate;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/v5/v5_arena_scene_reconstruction.jpg',
    fit: BoxFit.cover,
    alignment: Alignment.center,
    filterQuality: FilterQuality.high,
    semanticLabel: 'ROUNDVEIL arena with the approved hooded hero artwork',
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
                        size: widget.compact ? 54 : 105,
                        color: widget.color.withValues(alpha: .19),
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
                      horizontal: widget.compact ? 12 : 23,
                      vertical: widget.compact ? 8 : 18,
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
                            fontSize: widget.compact ? 7 : 10,
                            letterSpacing: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: widget.compact ? 5 : 9),
                        Text(
                          widget.title.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.compact ? 15 : 26,
                            height: .95,
                            letterSpacing: .5,
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
                    right: widget.compact ? 8 : 15,
                    bottom: widget.compact ? 7 : 12,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: widget.compact ? 17 : 25,
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
    final portraitSize = compact ? 39.0 : 62.0;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 5 : 8),
      child: Material(
        color: const Color(0x7A07152A),
        child: InkWell(
          onTap: filled ? null : onTap,
          child: SizedBox(
            height: compact ? 45 : 70,
            child: Row(
              children: <Widget>[
                if (filled && appearance != null)
                  SizedBox(
                    width: portraitSize,
                    height: portraitSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.asset(
                          'assets/brand/roundveil_mascot_portrait.webp',
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          semanticLabel:
                              'Official ROUNDVEIL character portrait',
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(appearance!.accentColor),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ],
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
                SizedBox(width: compact ? 5 : 9),
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
                          fontSize: compact ? 7 : 10,
                          letterSpacing: .4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (filled)
                        Text(
                          'READY',
                          style: TextStyle(
                            color: tokens.cyan,
                            fontSize: compact ? 6 : 8,
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
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: compact ? 14 : 18,
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
  const _GameModeRail({
    required this.compact,
    required this.onTap,
    required this.onCreate,
  });
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: <Widget>[
        SizedBox(
          width: compact ? 190 : 205,
          child: _PlayTogetherAction(compact: compact, onTap: onCreate),
        ),
        SizedBox(width: compact ? 6 : 15),
        if (!compact)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 190,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CHOOSE YOUR GAME',
                    style: TextStyle(
                      color: tokens.cyan,
                      fontSize: 10,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BUILD A ROUND OR MIX MODES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                      letterSpacing: .7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: gameCatalog.length,
            separatorBuilder: (_, _) => SizedBox(width: compact ? 5 : 9),
            itemBuilder: (context, index) {
              final game = gameCatalog[index];
              return SizedBox(
                width: compact ? 83 : 132,
                child: Material(
                  color: const Color(0xB309172B),
                  child: InkWell(
                    onTap: onTap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        _GameModeArtwork(
                          gameId: game.id,
                          color: game.playable ? tokens.orange : tokens.cyan,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color(0x08030B18),
                                Color(0xF0030B18),
                              ],
                              stops: <double>[.1, 1],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 5 : 9,
                              2,
                              3,
                              compact ? 5 : 8,
                            ),
                            child: Text(
                              _gameTitle(l10n, game.titleKey).toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 7 : 10,
                                height: 1.0,
                                letterSpacing: .2,
                                fontWeight: FontWeight.w900,
                                shadows: const <Shadow>[
                                  Shadow(color: Colors.black, blurRadius: 7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 2,
                          child: ColoredBox(
                            color: game.playable ? tokens.orange : tokens.cyan,
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
    );
  }
}

class _PlayTogetherAction extends StatelessWidget {
  const _PlayTogetherAction({required this.compact, required this.onTap});
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xC50A1729),
    child: InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: compact ? 36 : 62,
            height: double.infinity,
            child: Icon(
              Icons.groups_rounded,
              color: const Color(0xFFFFAB3D),
              size: compact ? 29 : 48,
            ),
          ),
          SizedBox(width: compact ? 5 : 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  compact ? 'PLAY' : 'PLAY TOGETHER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 7 : 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                Text(
                  compact ? 'SQUAD' : 'CHALLENGE TOGETHER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF61D9FF),
                    fontSize: compact ? 6 : 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _GameModeArtwork extends StatelessWidget {
  const _GameModeArtwork({required this.gameId, required this.color});
  final String gameId;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = switch (gameId) {
      'quiz' => Icons.psychology_alt_rounded,
      'word_play' => Icons.abc_rounded,
      'guess_character' => Icons.person_search_rounded,
      'guess_country_flags' => Icons.flag_rounded,
      _ => Icons.sports_esports_rounded,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[const Color(0xFF16334A), const Color(0xFF06101C)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(painter: _ModeGlyphPainter(color)),
          Align(
            alignment: const Alignment(.15, -.12),
            child: Icon(icon, size: 45, color: color.withValues(alpha: .9)),
          ),
        ],
      ),
    );
  }
}

class _ModeGlyphPainter extends CustomPainter {
  const _ModeGlyphPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..moveTo(0, size.height * .8)
      ..lineTo(size.width * .44, size.height * .15)
      ..lineTo(size.width, size.height * .52);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .22),
      size.shortestSide * .28,
      stroke,
    );
  }

  @override
  bool shouldRepaint(_ModeGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

String _gameTitle(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quiz,
  'wordPlay' => l10n.wordPlay,
  'guessCharacter' => l10n.guessCharacter,
  'guessCountry' => l10n.guessCountry,
  _ => key,
};
