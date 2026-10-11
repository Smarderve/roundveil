import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

class V5LobbyPage extends StatelessWidget {
  const V5LobbyPage({
    required this.players,
    required this.onPlayersChanged,
    required this.onCreate,
    required this.onQuick,
    required this.onDrafts,
    required this.onGames,
    required this.onAvatars,
    super.key,
  });

  final List<PlayerConfiguration> players;
  final ValueChanged<List<PlayerConfiguration>> onPlayersChanged;
  final ValueChanged<List<PlayerConfiguration>> onCreate;
  final VoidCallback onQuick;
  final VoidCallback onDrafts;
  final VoidCallback onGames;
  final VoidCallback onAvatars;

  void _addPlayer() {
    if (players.length >= 12) return;
    onPlayersChanged(<PlayerConfiguration>[
      ...players,
      PlayerConfiguration.placeholder(players.length + 1),
    ]);
  }

  void _removePlayer() {
    if (players.isEmpty) return;
    onPlayersChanged(
      List<PlayerConfiguration>.generate(
        players.length - 1,
        (index) => PlayerConfiguration.placeholder(index + 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 1050 || size.height < 570;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 210);
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF061226)),
      child: compact ? _compact(context, motion) : _desktop(context, motion),
    );
  }

  Widget _compact(BuildContext context, Duration motion) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 142,
                  child: _SquadDock(
                    players: players,
                    onAdd: _addPlayer,
                    onRemove: _removePlayer,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: V5SceneArt()),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * .34,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: _CommandCard(
                          title: l10n.createGame.toUpperCase(),
                          subtitle: l10n.sessionTitle.toUpperCase(),
                          icon: Icons.sports_martial_arts_rounded,
                          color: tokens.orange,
                          onTap: () => onCreate(players),
                          duration: motion,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Expanded(
                        child: _CommandCard(
                          title: l10n.quickGame.toUpperCase(),
                          subtitle: l10n.templateDescription.toUpperCase(),
                          icon: Icons.bolt_rounded,
                          color: tokens.cyan,
                          onTap: onQuick,
                          duration: motion,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 42,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _FeatureButton(
                                icon: Icons.description_outlined,
                                label: l10n.savedDrafts,
                                onTap: onDrafts,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _FeatureButton(
                                icon: Icons.face_rounded,
                                label: 'Avatars',
                                onTap: onAvatars,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(height: 54, child: _GameModeRail(onTap: onGames)),
        ],
      ),
    );
  }

  Widget _desktop(BuildContext context, Duration motion) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 205,
                  child: _SquadDock(
                    players: players,
                    onAdd: _addPlayer,
                    onRemove: _removePlayer,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(child: V5SceneArt()),
                const SizedBox(width: 18),
                SizedBox(
                  width: 385,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: _CommandCard(
                          title: l10n.createGame.toUpperCase(),
                          subtitle: l10n.sessionTitle.toUpperCase(),
                          icon: Icons.sports_martial_arts_rounded,
                          color: tokens.orange,
                          onTap: () => onCreate(players),
                          duration: motion,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _CommandCard(
                          title: l10n.quickGame.toUpperCase(),
                          subtitle: l10n.templateDescription.toUpperCase(),
                          icon: Icons.bolt_rounded,
                          color: tokens.cyan,
                          onTap: onQuick,
                          duration: motion,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _FeatureButton(
                              icon: Icons.description_outlined,
                              label: l10n.savedDrafts,
                              onTap: onDrafts,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _FeatureButton(
                              icon: Icons.face_rounded,
                              label: 'Avatars',
                              onTap: onAvatars,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 94, child: _GameModeRail(onTap: onGames)),
        ],
      ),
    );
  }
}

class V5SceneArt extends StatefulWidget {
  const V5SceneArt({super.key});
  @override
  State<V5SceneArt> createState() => _V5SceneArtState();
}

class _V5SceneArtState extends State<V5SceneArt> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.load(
        'assets/brand/approved_home_v5_scene_source.webp',
      );
      final codec = await ui.instantiateImageCodec(Uint8List.sublistView(data));
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _image = frame.image);
    } on FlutterError {
      // Flutter's widget-test asset bundle may omit packaged binary assets.
      // The real Windows and Android app bundles include this source artwork.
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: Color(0xFF071326)),
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        CustomPaint(painter: _V5ScenePainter(_image)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x18030B18),
                Colors.transparent,
                Color(0xB8030B18),
              ],
            ),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 8,
          child: Text(
            'ROUNDVEIL ARENA',
            style: TextStyle(
              color: Theme.of(context).extension<RoundveilBrandTokens>()!.cyan,
              fontSize: 9,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _V5ScenePainter extends CustomPainter {
  const _V5ScenePainter(this.image);
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    final artwork = image;
    if (artwork == null || size.isEmpty) return;
    final sourceBounds = Rect.fromLTWH(
      0,
      0,
      artwork.width.toDouble(),
      artwork.height.toDouble(),
    );
    final source = Rect.fromLTRB(
      sourceBounds.width * .27,
      sourceBounds.height * .13,
      sourceBounds.width * .64,
      sourceBounds.height * .82,
    );
    // Preserve the complete approved character crop on wide landscape phones.
    // Covering this short-height viewport cut off both the hood and lower pose.
    final fit = applyBoxFit(BoxFit.contain, source.size, size);
    canvas.drawImageRect(
      artwork,
      Alignment.center.inscribe(fit.source, source),
      Alignment.center.inscribe(fit.destination, Offset.zero & size),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_V5ScenePainter oldDelegate) => oldDelegate.image != image;
}

class _CommandCard extends StatefulWidget {
  const _CommandCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.duration,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Duration duration;
  @override
  State<_CommandCard> createState() => _CommandCardState();
}

class _CommandCardState extends State<_CommandCard> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() {
      _hover = false;
      _down = false;
    }),
    child: GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down
            ? .985
            : _hover
            ? 1.012
            : 1,
        duration: widget.duration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: ClipPath(
              clipper: const _AngularClipper(),
              child: AnimatedContainer(
                duration: widget.duration,
                decoration: BoxDecoration(
                  border: Border.all(color: widget.color, width: 1.7),
                  gradient: LinearGradient(
                    colors: <Color>[
                      widget.color.withValues(alpha: .56),
                      const Color(0xF20A1630),
                      const Color(0xD9071227),
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.color.withValues(alpha: _hover ? .48 : .22),
                      blurRadius: _hover ? 24 : 12,
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(width: 7, color: widget.color),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: <Widget>[
                            Icon(widget.icon, size: 36, color: widget.color),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.sizeOf(context).width < 800
                                          ? 15
                                          : 25,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .9,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: widget.color,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: widget.color,
                              size: 31,
                            ),
                          ],
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
    ),
  );
}

class _AngularClipper extends CustomClipper<Path> {
  const _AngularClipper();
  @override
  Path getClip(Size size) => Path()
    ..moveTo(15, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - 15)
    ..lineTo(size.width - 15, size.height)
    ..lineTo(0, size.height)
    ..lineTo(0, 15)
    ..close();
  @override
  bool shouldReclip(_AngularClipper oldClipper) => false;
}

class _SquadDock extends StatelessWidget {
  const _SquadDock({
    required this.players,
    required this.onAdd,
    required this.onRemove,
  });
  final List<PlayerConfiguration> players;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.groups_rounded, color: tokens.cyan, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'YOUR SQUAD',
                style: TextStyle(
                  color: tokens.cyan,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${players.length}/12',
              style: TextStyle(color: tokens.muted, fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (var index = 0; index < players.length; index++)
                  _PlayerSlot(
                    number: index + 1,
                    name: players[index].displayName,
                    filled: true,
                    onTap: onRemove,
                  ),
                if (players.length < 12)
                  _PlayerSlot(
                    number: players.length + 1,
                    name: 'ADD PLAYER',
                    filled: false,
                    onTap: onAdd,
                  ),
              ],
            ),
          ),
        ),
        if (players.isNotEmpty)
          TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 16),
            label: Text(l10n.removePlayer.toUpperCase()),
          ),
      ],
    );
  }
}

class _PlayerSlot extends StatelessWidget {
  const _PlayerSlot({
    required this.number,
    required this.name,
    required this.filled,
    required this.onTap,
  });
  final int number;
  final String name;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: const Color(0xB30A1830),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: filled ? tokens.orange : tokens.cyan,
                  width: 3,
                ),
                bottom: BorderSide(color: tokens.cyan.withValues(alpha: .32)),
              ),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  child: Icon(
                    filled
                        ? Icons.person_rounded
                        : Icons.person_add_alt_1_rounded,
                    color: filled ? tokens.orange : tokens.cyan,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Text(
                    filled
                        ? name.toUpperCase()
                        : 'PLAYER ${number.toString().padLeft(2, '0')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: filled ? Colors.white : tokens.muted,
                      fontSize: 9,
                      letterSpacing: .7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  filled ? Icons.check_circle_rounded : Icons.add_rounded,
                  color: tokens.cyan,
                  size: 16,
                ),
                const SizedBox(width: 8),
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
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Material(
      color: const Color(0xB80B1B32),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(icon, color: tokens.cyan, size: 16),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
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
}

class _GameModeRail extends StatelessWidget {
  const _GameModeRail({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'PICK YOUR MODE',
                style: TextStyle(
                  color: tokens.cyan,
                  fontSize: 9,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'MORE GAMES · MORE ROUNDS',
                style: TextStyle(
                  color: tokens.muted,
                  fontSize: 8,
                  letterSpacing: .6,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: gameCatalog.length,
            separatorBuilder: (_, _) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final game = gameCatalog[index];
              return Material(
                color: const Color(0xD00A1930),
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    width: 128,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: tokens.cyan.withValues(alpha: .55),
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          _iconFor(game.id),
                          color: game.playable ? tokens.orange : tokens.cyan,
                          size: 20,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            _gameTitle(l10n, game.titleKey).toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
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
    );
  }
}

IconData _iconFor(String id) => switch (id) {
  'quiz' => Icons.quiz_outlined,
  'word_play' => Icons.text_fields_rounded,
  'guess_character' => Icons.person_search_outlined,
  'riddles' => Icons.lightbulb_outline_rounded,
  'memory' => Icons.grid_view_rounded,
  'guess_country_flags' => Icons.flag_outlined,
  _ => Icons.sports_esports_outlined,
};

String _gameTitle(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quiz,
  'wordPlay' => l10n.wordPlay,
  'guessCharacter' => l10n.guessCharacter,
  'riddles' => l10n.riddles,
  'memory' => l10n.memory,
  'guessCountry' => l10n.guessCountry,
  _ => key,
};
