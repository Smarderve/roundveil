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
    onPlayersChanged(players.take(players.length - 1).toList());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 1050 || size.height < 570;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = compact ? 136.0 : 208.0;
        final right = compact
            ? (constraints.maxWidth * .34).clamp(260.0, 360.0)
            : (constraints.maxWidth * .27).clamp(350.0, 450.0);
        final bottom = compact ? 62.0 : 96.0;
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
                    Color(0x18020A16),
                    Color(0x12020A16),
                    Color(0xBF020A16),
                  ],
                ),
              ),
            ),
            Positioned(
              left: compact ? 7 : 22,
              top: compact ? 8 : 18,
              bottom: bottom + (compact ? 9 : 16),
              width: side,
              child: _SquadDock(
                players: players,
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
                      imageSource: const Rect.fromLTWH(.79, .18, .14, .14),
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
                      imageSource: const Rect.fromLTWH(.875, .505, .075, .08),
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

class V5SceneArt extends StatelessWidget {
  const V5SceneArt({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/v5/v5_arena_scene_reconstruction.jpg',
    fit: BoxFit.cover,
    alignment: const Alignment(.03, -1),
    errorBuilder: (context, error, stack) => const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF132D4A), Color(0xFF061226)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}

class _CommandCard extends StatefulWidget {
  const _CommandCard({
    required this.title,
    required this.subtitle,
    required this.imageSource,
    required this.color,
    required this.onTap,
    required this.compact,
  });
  final String title;
  final String subtitle;
  final Rect imageSource;
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
                  _SourceArtwork(source: widget.imageSource),
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
    required this.compact,
    required this.onAdd,
    required this.onRemove,
    required this.onPortraits,
  });
  final List<PlayerConfiguration> players;
  final bool compact;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onPortraits;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final portraitRects = <Rect>[
      const Rect.fromLTWH(.034, .255, .048, .061),
      const Rect.fromLTWH(.034, .355, .048, .061),
      const Rect.fromLTWH(.034, .455, .048, .061),
      const Rect.fromLTWH(.034, .555, .048, .061),
    ];
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
                  filled: true,
                  compact: compact,
                  source: portraitRects[index % portraitRects.length],
                  onTap: onRemove,
                ),
              if (players.length < 12)
                _PlayerSlot(
                  number: players.length + 1,
                  name: 'ADD PLAYER',
                  filled: false,
                  compact: compact,
                  source: null,
                  onTap: onAdd,
                ),
            ],
          ),
        ),
        if (players.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onRemove,
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
    required this.filled,
    required this.compact,
    required this.source,
    required this.onTap,
  });
  final int number;
  final String name;
  final bool filled;
  final bool compact;
  final Rect? source;
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
          onTap: onTap,
          child: SizedBox(
            height: compact ? 45 : 70,
            child: Row(
              children: <Widget>[
                if (filled && source != null)
                  SizedBox(
                    width: portraitSize,
                    height: portraitSize,
                    child: _SourceArtwork(source: source!, fit: BoxFit.cover),
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
    final artRects = <Rect>[
      const Rect.fromLTWH(.275, .817, .070, .083),
      const Rect.fromLTWH(.350, .817, .070, .083),
      const Rect.fromLTWH(.425, .817, .070, .083),
      const Rect.fromLTWH(.500, .817, .070, .083),
      const Rect.fromLTWH(.575, .817, .070, .083),
      const Rect.fromLTWH(.650, .817, .075, .083),
    ];
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
                        _SourceArtwork(
                          source: artRects[index % artRects.length],
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
            child: const _SourceArtwork(
              source: Rect.fromLTWH(.015, .858, .09, .105),
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

Future<ui.Image?>? _sourceArtworkFuture;

class _SourceArtwork extends StatefulWidget {
  const _SourceArtwork({required this.source, this.fit = BoxFit.cover});
  final Rect source;
  final BoxFit fit;

  @override
  State<_SourceArtwork> createState() => _SourceArtworkState();
}

class _SourceArtworkState extends State<_SourceArtwork> {
  late final Future<ui.Image?> _future;

  @override
  void initState() {
    super.initState();
    _future = _sourceArtworkFuture ??= _loadSourceArtwork();
  }

  Future<ui.Image?> _loadSourceArtwork() async {
    try {
      final data = await rootBundle.load(
        'assets/brand/approved_home_v5_scene_source.webp',
      );
      final codec = await ui.instantiateImageCodec(Uint8List.sublistView(data));
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    } on FlutterError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Image?>(
    future: _future,
    builder: (context, snapshot) => CustomPaint(
      painter: _SourceArtworkPainter(snapshot.data, widget.source, widget.fit),
      child: const SizedBox.expand(),
    ),
  );
}

class _SourceArtworkPainter extends CustomPainter {
  const _SourceArtworkPainter(this.image, this.normalizedSource, this.fit);
  final ui.Image? image;
  final Rect normalizedSource;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final artwork = image;
    if (artwork == null || size.isEmpty) return;
    final source = Rect.fromLTWH(
      normalizedSource.left * artwork.width,
      normalizedSource.top * artwork.height,
      normalizedSource.width * artwork.width,
      normalizedSource.height * artwork.height,
    );
    final fitted = applyBoxFit(fit, source.size, size);
    canvas.drawImageRect(
      artwork,
      Alignment.center.inscribe(fitted.source, source),
      Alignment.center.inscribe(fitted.destination, Offset.zero & size),
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(_SourceArtworkPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.normalizedSource != normalizedSource ||
      oldDelegate.fit != fit;
}

String _gameTitle(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quiz,
  'wordPlay' => l10n.wordPlay,
  'guessCharacter' => l10n.guessCharacter,
  'riddles' => l10n.riddles,
  'memory' => l10n.memory,
  'guessCountry' => l10n.guessCountry,
  _ => key,
};
