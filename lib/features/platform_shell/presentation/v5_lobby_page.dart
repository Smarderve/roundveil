import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_avatar_catalog.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/guess_country/presentation/player_avatar_figure.dart';
import 'package:roundveil/features/platform_shell/presentation/create_player_dialog.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

/// Interactive Version 5 lobby composition. The scene plate is artwork only;
/// navigation, squad editing, profile selection and launch actions stay real
/// Flutter controls above it.
class V5LobbyPage extends StatefulWidget {
  const V5LobbyPage({
    required this.players,
    required this.profiles,
    required this.selectedProfileId,
    required this.onSelectedProfileChanged,
    required this.onCreateProfile,
    required this.onPlayersChanged,
    required this.onCreate,
    required this.onQuick,
    required this.onDrafts,
    required this.onGames,
    required this.onLaunchGame,
    required this.onAvatars,
    required this.onProfileChanged,
    super.key,
  });

  final List<PlayerConfiguration> players;
  final List<PlayerProfile> profiles;
  final String? selectedProfileId;
  final ValueChanged<String> onSelectedProfileChanged;
  final Future<PlayerProfile> Function(String, PlayerGender?, String)
  onCreateProfile;
  final ValueChanged<List<PlayerConfiguration>> onPlayersChanged;
  final ValueChanged<List<PlayerConfiguration>> onCreate;
  final VoidCallback onQuick;
  final VoidCallback onDrafts;
  final VoidCallback onGames;
  final ValueChanged<String> onLaunchGame;
  final VoidCallback onAvatars;
  final ValueChanged<PlayerProfile> onProfileChanged;

  @override
  State<V5LobbyPage> createState() => _V5LobbyPageState();
}

class _V5LobbyPageState extends State<V5LobbyPage> {
  PlayerProfile? get _selectedProfile =>
      widget.profiles
          .where((profile) => profile.id == widget.selectedProfileId)
          .firstOrNull ??
      widget.profiles.firstOrNull;

  void _stepProfile(int direction) {
    final profile = _selectedProfile;
    if (profile == null || widget.profiles.length < 2) return;
    final current = widget.profiles.indexWhere((item) => item.id == profile.id);
    final next =
        (current + direction + widget.profiles.length) % widget.profiles.length;
    widget.onSelectedProfileChanged(widget.profiles[next].id);
  }

  Future<void> _addPlayer() async {
    if (widget.players.length >= 12) return;
    final draft = await showCreatePlayerDialog(
      context,
      existingProfiles: widget.profiles,
    );
    if (!mounted || draft == null) return;
    try {
      final profile = await widget.onCreateProfile(
        draft.displayName,
        draft.gender,
        draft.avatarId,
      );
      if (!mounted) return;
      widget.onPlayersChanged(<PlayerConfiguration>[
        ...widget.players,
        PlayerConfiguration(id: profile.id, displayName: profile.displayName),
      ]);
      widget.onSelectedProfileChanged(profile.id);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create player: $error')),
      );
    }
  }

  void _removePlayer(String playerId) => widget.onPlayersChanged(
    widget.players.where((player) => player.id != playerId).toList(),
  );

  Future<void> _editCallsSign(PlayerProfile? profile) async {
    if (profile == null) return;
    var draft = profile.displayName;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('RENAME PLAYER'),
        content: TextFormField(
          autofocus: true,
          initialValue: draft,
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => draft = value,
          onFieldSubmitted: (_) => Navigator.of(dialogContext).pop(draft),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, draft),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty || !mounted) return;
    widget.onProfileChanged(profile.copyWith(displayName: trimmed));
  }

  Future<void> _openAvatarSelector(PlayerProfile profile) => showDialog<void>(
    context: context,
    barrierColor: const Color(0xD9000610),
    builder: (dialogContext) => _AvatarSelectorDialog(
      profile: profile,
      assignedAvatarIds: widget.profiles
          .where((item) => item.id != profile.id)
          .map((item) => item.avatarId)
          .toSet(),
      onSelect: (avatarId) =>
          widget.onProfileChanged(profile.copyWith(avatarId: avatarId)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final narrow = size.width < 760;
    final compact = size.width < 1100;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final activeProfile = _selectedProfile;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final shortLandscape = height < 460;
        final side = narrow
            ? 112.0
            : compact
            ? 158.0
            : (width * .17).clamp(196.0, 238.0);
        final right = narrow
            ? 184.0
            : compact
            ? (width * .25).clamp(222.0, 292.0)
            : (width * .25).clamp(318.0, 390.0);
        final bottom = height < 460
            ? 100.0
            : height < 640
            ? 118.0
            : 150.0;
        final contentTop = compact ? 55.0 : 72.0;
        final sideInset = narrow
            ? 7.0
            : compact
            ? 12.0
            : 22.0;
        final actionInset = narrow
            ? 7.0
            : compact
            ? 12.0
            : 24.0;
        final railInset = narrow
            ? 9.0
            : compact
            ? 18.0
            : 34.0;
        final centerLeft = sideInset + side + 5;
        final centerRight = actionInset + right + 5;
        final centerWidth = math.max(0.0, width - centerLeft - centerRight);
        final availableHeroHeight = math.max(
          0.0,
          height - contentTop - bottom - 8,
        );
        final heroHeight = math.min(availableHeroHeight, height * .72);
        final heroWidth = math.min(centerWidth * .86, heroHeight * .84);
        final heroLeft = centerLeft + (centerWidth - heroWidth) / 2;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const _LobbyEnvironment(),
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
                top: contentTop + (height < 500 ? 0 : 7),
                width: heroWidth,
                height: heroHeight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Semantics(
                    button: true,
                    label: 'Change ${activeProfile.displayName} avatar',
                    child: Tooltip(
                      message: 'Choose avatar',
                      child: InkWell(
                        key: const ValueKey<String>('home-avatar-selector'),
                        onTap: () => _openAvatarSelector(activeProfile),
                        child: PlayerAvatarFigure(
                          key: ValueKey<String>(
                            'lobby-hero-${activeProfile.id}',
                          ),
                          avatarId: activeProfile.avatarId,
                          appearance: activeProfile.avatar,
                          width: heroWidth,
                          height: heroHeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: sideInset,
              top: contentTop,
              bottom: bottom + 9,
              width: side,
              child: _SquadDock(
                players: widget.players,
                profiles: widget.profiles,
                compact: compact,
                onAdd: _addPlayer,
                onRemove: _removePlayer,
                selectedProfileId: widget.selectedProfileId,
                onSelectProfile: widget.onSelectedProfileChanged,
                onPortraits: widget.onAvatars,
              ),
            ),
            Positioned(
              right: actionInset,
              top: contentTop,
              bottom: bottom + 9,
              width: right,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: shortLandscape
                        ? 42
                        : compact
                        ? 50
                        : 66,
                    child: _ProfileSelectionRail(
                      profile: activeProfile,
                      profileCount: widget.profiles.length,
                      onStep: _stepProfile,
                      onRename: () => _editCallsSign(activeProfile),
                    ),
                  ),
                  SizedBox(
                    height: shortLandscape
                        ? 5
                        : compact
                        ? 8
                        : 12,
                  ),
                  SizedBox(
                    height: shortLandscape
                        ? 58
                        : compact
                        ? 70
                        : 92,
                    child: _CommandCard(
                      title: AppLocalizations.of(context)!.quickGame,
                      subtitle: 'FIND A MATCH AND PLAY INSTANTLY',
                      icon: Icons.bolt_rounded,
                      color: tokens.orange,
                      onTap: widget.onQuick,
                      compact: compact,
                    ),
                  ),
                  SizedBox(
                    height: shortLandscape
                        ? 5
                        : compact
                        ? 7
                        : 10,
                  ),
                  SizedBox(
                    height: shortLandscape
                        ? 52
                        : compact
                        ? 66
                        : 80,
                    child: _CommandCard(
                      title: AppLocalizations.of(context)!.createGame,
                      subtitle: 'SET RULES AND INVITE PLAYERS',
                      icon: Icons.groups_rounded,
                      color: tokens.cyan,
                      onTap: () => widget.onCreate(widget.players),
                      compact: compact,
                    ),
                  ),
                  SizedBox(
                    height: shortLandscape
                        ? 5
                        : compact
                        ? 7
                        : 10,
                  ),
                  SizedBox(
                    height: shortLandscape
                        ? 32
                        : compact
                        ? 36
                        : 44,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _FeatureButton(
                            icon: Icons.description_outlined,
                            label: AppLocalizations.of(context)!.savedDrafts,
                            onTap: widget.onDrafts,
                          ),
                        ),
                        SizedBox(width: compact ? 7 : 10),
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
              left: railInset,
              right: railInset,
              bottom: compact ? 7 : 14,
              height: bottom,
              child: Center(
                child: _GameModeRail(
                  compact: compact,
                  onSelectGame: widget.onLaunchGame,
                ),
              ),
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
    required this.onRename,
  });
  final PlayerProfile? profile;
  final int profileCount;
  final ValueChanged<int> onStep;
  final VoidCallback onRename;

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
              avatarId: profile.avatarId,
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
                      fontSize: compact ? 10 : 13,
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
                      fontSize: compact ? 7.5 : 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Rename ${profile.displayName}',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 26, height: 30),
            padding: EdgeInsets.zero,
            onPressed: onRename,
            icon: const Icon(Icons.edit_outlined, size: 15),
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

/// A restrained indoor player-select studio keeps the avatar in focus without
/// borrowing a recognizable map or relying on a flattened concept screenshot.
class _LobbyEnvironment extends StatelessWidget {
  const _LobbyEnvironment();

  @override
  Widget build(BuildContext context) => const Stack(
    fit: StackFit.expand,
    children: <Widget>[
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF071422),
              Color(0xFF0B1C2C),
              Color(0xFF040A12),
            ],
            stops: <double>[0, .58, 1],
          ),
        ),
      ),
      CustomPaint(painter: _LobbyEnvironmentPainter()),
    ],
  );
}

class _LobbyEnvironmentPainter extends CustomPainter {
  const _LobbyEnvironmentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final floorY = size.height * .76;
    final blue = const Color(0xFF2DA9F2);
    final amber = const Color(0xFFFF8A2B);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.width * .00075);

    // Diffuse studio spill behind the character, with cooler and warmer sides.
    for (final (center, color, radius) in <(Offset, Color, double)>[
      (Offset(size.width * .37, size.height * .47), blue, size.width * .38),
      (Offset(size.width * .73, size.height * .38), amber, size.width * .24),
    ]) {
      final glow = Paint()
        ..shader = RadialGradient(
          colors: <Color>[color.withValues(alpha: .16), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawRect(Offset.zero & size, glow);
    }

    // Tall beveled acoustic panels imply a purpose-built indoor character bay.
    for (var index = 0; index < 5; index++) {
      final t = index / 4;
      final x = size.width * (.035 + t * .93);
      final inward = (index.isEven ? 1 : -1) * size.width * .018;
      final panel = Path()
        ..moveTo(x, size.height * .08)
        ..lineTo(x + inward, size.height * .16)
        ..lineTo(x + inward, floorY)
        ..lineTo(x, floorY - size.height * .025);
      stroke
        ..color = const Color(0x273A7290)
        ..strokeWidth = math.max(1, size.width * .0009);
      canvas.drawPath(panel, stroke);
      if (index == 0 || index == 4) {
        final edgeX = x + inward * .52;
        stroke
          ..color = (index == 0 ? blue : amber).withValues(alpha: .62)
          ..strokeWidth = math.max(2, size.width * .0015);
        canvas.drawLine(
          Offset(edgeX, size.height * .2),
          Offset(edgeX, floorY * .91),
          stroke,
        );
      }
    }

    // Receding overhead gantry and paired spotlights; all geometry is drawn
    // from the available viewport so landscape phones do not inherit desktop
    // pixel dimensions.
    final gantry = Path()
      ..moveTo(size.width * .08, size.height * .04)
      ..lineTo(size.width * .5, size.height * .13)
      ..lineTo(size.width * .92, size.height * .04);
    stroke
      ..color = const Color(0x304B819B)
      ..strokeWidth = math.max(2, size.width * .002);
    canvas.drawPath(gantry, stroke);
    for (final x in <double>[.2, .8]) {
      final lightColor = x < .5 ? blue : amber;
      final beam = Path()
        ..moveTo(size.width * x, size.height * .14)
        ..lineTo(size.width * (x - .13), floorY)
        ..lineTo(size.width * (x + .13), floorY)
        ..close();
      canvas.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              lightColor.withValues(alpha: .08),
              lightColor.withValues(alpha: .008),
            ],
          ).createShader(Offset.zero & size),
      );
      canvas.drawCircle(
        Offset(size.width * x, size.height * .14),
        math.max(3, size.width * .003),
        Paint()..color = lightColor.withValues(alpha: .85),
      );
    }

    // A shallow, illuminated presentation dais anchors the character in the
    // scene and gives the composition a clear ground plane.
    final floor = Path()
      ..moveTo(0, floorY)
      ..lineTo(size.width * .5, floorY + size.height * .035)
      ..lineTo(size.width, floorY)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      floor,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF101D29), Color(0xFF03070D)],
        ).createShader(Offset.zero & size),
    );

    final dais = Path()
      ..moveTo(size.width * .22, floorY + size.height * .08)
      ..lineTo(size.width * .5, floorY + size.height * .035)
      ..lineTo(size.width * .78, floorY + size.height * .08)
      ..lineTo(size.width * .66, floorY + size.height * .15)
      ..lineTo(size.width * .34, floorY + size.height * .15)
      ..close();
    canvas.drawPath(dais, Paint()..color = const Color(0xFF111E2B));
    stroke
      ..color = const Color(0x9942BDF0)
      ..strokeWidth = math.max(2, size.width * .002);
    canvas.drawLine(
      Offset(size.width * .26, floorY + size.height * .085),
      Offset(size.width * .5, floorY + size.height * .045),
      stroke,
    );
    stroke
      ..color = amber.withValues(alpha: .78)
      ..strokeWidth = math.max(1.5, size.width * .0013);
    canvas.drawLine(
      Offset(size.width * .5, floorY + size.height * .045),
      Offset(size.width * .74, floorY + size.height * .085),
      stroke,
    );

    final horizon = Offset(size.width * .5, floorY + size.height * .1);
    stroke
      ..color = const Color(0x1F5A9DB8)
      ..strokeWidth = 1;
    for (var index = 0; index <= 10; index++) {
      final x = size.width * index / 10;
      canvas.drawLine(horizon, Offset(x, size.height), stroke);
    }
    for (var index = 1; index <= 4; index++) {
      final t = index / 4;
      final y = horizon.dy + (size.height - horizon.dy) * t * t;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _LobbyEnvironmentPainter oldDelegate) => false;
}

class _AvatarSelectorDialog extends StatefulWidget {
  const _AvatarSelectorDialog({
    required this.profile,
    required this.assignedAvatarIds,
    required this.onSelect,
  });

  final PlayerProfile profile;
  final Set<String> assignedAvatarIds;
  final ValueChanged<String> onSelect;

  @override
  State<_AvatarSelectorDialog> createState() => _AvatarSelectorDialogState();
}

class _AvatarSelectorDialogState extends State<_AvatarSelectorDialog> {
  late int _previewIndex = PlayerAvatarCatalog.all.indexWhere(
    (avatar) => avatar.id == widget.profile.avatarId,
  );

  int get _safeIndex => _previewIndex < 0 ? 0 : _previewIndex;

  void _step(int delta) => setState(() {
    var index = _safeIndex;
    for (
      var attempts = 0;
      attempts < PlayerAvatarCatalog.all.length;
      attempts++
    ) {
      index =
          (index + delta + PlayerAvatarCatalog.all.length) %
          PlayerAvatarCatalog.all.length;
      if (index == _safeIndex ||
          !widget.assignedAvatarIds.contains(
            PlayerAvatarCatalog.all[index].id,
          )) {
        _previewIndex = index;
        return;
      }
    }
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final avatar = PlayerAvatarCatalog.all[_safeIndex];
    final preview = Container(
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: <Color>[Color(0xFF153550), Color(0xFF071321)],
        ),
        border: Border.all(color: const Color(0x5537B7E9)),
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: PlayerAvatarFigure(
              key: ValueKey<String>('avatar-selector-preview-${avatar.id}'),
              avatarId: avatar.id,
              appearance: widget.profile.avatar,
              width: compact ? 210 : 286,
              height: compact ? 280 : 390,
            ),
          ),
          Positioned(
            left: 5,
            top: 0,
            bottom: 0,
            child: _AvatarStepButton(
              label: 'Previous avatar',
              icon: Icons.chevron_left_rounded,
              onPressed: () => _step(-1),
            ),
          ),
          Positioned(
            right: 5,
            top: 0,
            bottom: 0,
            child: _AvatarStepButton(
              label: 'Next avatar',
              icon: Icons.chevron_right_rounded,
              onPressed: () => _step(1),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xD9071424)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  '${avatar.name}  ·  ${_safeIndex + 1}/${PlayerAvatarCatalog.all.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Dialog(
      backgroundColor: const Color(0xFF071321),
      insetPadding: EdgeInsets.all(compact ? 10 : 34),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: size.height * .9,
          minWidth: compact ? 300 : 620,
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.face_rounded, color: Color(0xFF54D4F5)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'CHOOSE ${widget.profile.displayName.toUpperCase()}’S AVATAR',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close avatar selector',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: compact
                    ? Column(
                        children: <Widget>[
                          Expanded(child: preview),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 82,
                            child: _AvatarThumbnailRail(
                              selectedIndex: _safeIndex,
                              unavailableIds: widget.assignedAvatarIds,
                              onSelect: (index) =>
                                  setState(() => _previewIndex = index),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(flex: 3, child: preview),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 132,
                            child: _AvatarThumbnailRail(
                              selectedIndex: _safeIndex,
                              vertical: true,
                              unavailableIds: widget.assignedAvatarIds,
                              onSelect: (index) =>
                                  setState(() => _previewIndex = index),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  key: const ValueKey<String>('save-home-avatar-selection'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF49727),
                    foregroundColor: const Color(0xFF111820),
                    shape: const BeveledRectangleBorder(),
                  ),
                  onPressed: widget.assignedAvatarIds.contains(avatar.id)
                      ? null
                      : () {
                          widget.onSelect(avatar.id);
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('SELECT AVATAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarThumbnailRail extends StatelessWidget {
  const _AvatarThumbnailRail({
    required this.selectedIndex,
    required this.onSelect,
    required this.unavailableIds,
    this.vertical = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Set<String> unavailableIds;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final avatars = PlayerAvatarCatalog.all;
    return ListView.separated(
      scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
      itemCount: avatars.length,
      separatorBuilder: (context, index) =>
          SizedBox(width: vertical ? 0 : 7, height: vertical ? 7 : 0),
      itemBuilder: (context, index) => Semantics(
        button: true,
        selected: selectedIndex == index,
        label: '${avatars[index].name} avatar preview',
        child: InkWell(
          key: ValueKey<String>('preview-avatar-${avatars[index].id}'),
          onTap: unavailableIds.contains(avatars[index].id)
              ? null
              : () => onSelect(index),
          child: Container(
            width: vertical ? 112 : 70,
            height: vertical ? 74 : 78,
            decoration: BoxDecoration(
              border: Border.all(
                color: unavailableIds.contains(avatars[index].id)
                    ? Colors.white24
                    : selectedIndex == index
                    ? const Color(0xFFF49727)
                    : const Color(0x5537B7E9),
                width: selectedIndex == index ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  avatars[index].effectivePortraitAssetPath,
                  fit: BoxFit.cover,
                ),
                if (unavailableIds.contains(avatars[index].id))
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarStepButton extends StatelessWidget {
  const _AvatarStepButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: IconButton.filled(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xCC071321),
        foregroundColor: const Color(0xFF65D8FF),
        fixedSize: const Size(44, 52),
        shape: const BeveledRectangleBorder(),
      ),
      icon: Icon(icon),
    ),
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
                            fontSize: widget.compact ? 8 : 10,
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
                            fontSize: widget.compact ? 17 : 25,
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
    required this.selectedProfileId,
    required this.onSelectProfile,
    required this.compact,
    required this.onAdd,
    required this.onRemove,
    required this.onPortraits,
  });
  final List<PlayerConfiguration> players;
  final List<PlayerProfile> profiles;
  final String? selectedProfileId;
  final ValueChanged<String> onSelectProfile;
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
                  fontSize: compact ? 11 : 14,
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
              style: TextStyle(color: tokens.cyan, fontSize: compact ? 10 : 11),
            ),
          ],
        ),
        SizedBox(height: compact ? 6 : 12),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              for (var index = 0; index < players.length; index++)
                _PlayerSlot(
                  number: index + 1,
                  name:
                      profiles
                          .where((profile) => profile.id == players[index].id)
                          .firstOrNull
                          ?.displayName ??
                      players[index].displayName,
                  playerId: players[index].id,
                  filled: true,
                  compact: compact,
                  avatarId:
                      profiles
                          .where((profile) => profile.id == players[index].id)
                          .firstOrNull
                          ?.avatarId ??
                      PlayerAvatarCatalog.idForPlayer(index + 1),
                  appearance:
                      profiles
                          .where((profile) => profile.id == players[index].id)
                          .firstOrNull
                          ?.avatar ??
                      PlayerAvatarAppearance.forPlayer(index + 1),
                  selected: players[index].id == selectedProfileId,
                  onTap: () => onSelectProfile(players[index].id),
                  onRemove: () => onRemove(players[index].id),
                ),
              if (players.length < 12)
                _PlayerSlot(
                  number: players.length + 1,
                  name: 'ADD PLAYER',
                  playerId: null,
                  filled: false,
                  compact: compact,
                  avatarId: null,
                  appearance: null,
                  selected: false,
                  onTap: onAdd,
                  onRemove: () {},
                ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onPortraits,
          icon: Icon(Icons.face_retouching_natural, size: compact ? 14 : 17),
          label: const Text('CHOOSE AVATAR'),
          style: TextButton.styleFrom(
            foregroundColor: tokens.cyan,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            textStyle: TextStyle(
              fontSize: compact ? 10 : 12,
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
    required this.avatarId,
    required this.appearance,
    required this.onTap,
    required this.onRemove,
    required this.selected,
  });
  final int number;
  final String name;
  final String? playerId;
  final bool filled;
  final bool compact;
  final String? avatarId;
  final PlayerAvatarAppearance? appearance;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final portraitSize = compact ? 36.0 : 54.0;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 3 : 8),
      child: Material(
        color: selected ? const Color(0xB52276A4) : const Color(0x78071325),
        shape: Border(
          left: BorderSide(
            color: selected ? tokens.orange : Colors.transparent,
            width: selected ? 3 : 0,
          ),
        ),
        child: InkWell(
          key: playerId == null
              ? const ValueKey<String>('squad-add-player')
              : ValueKey<String>('squad-player-slot-$playerId'),
          onTap: onTap,
          child: SizedBox(
            height: compact ? 40 : 62,
            child: Row(
              children: <Widget>[
                if (filled && appearance != null)
                  SizedBox(
                    width: portraitSize,
                    height: portraitSize,
                    child: PlayerAvatarFigure(
                      key: ValueKey<String>('squad-portrait-$playerId'),
                      avatarId: avatarId,
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
                          fontSize: compact ? 9 : 11,
                          letterSpacing: .35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (filled)
                        Text(
                          'READY',
                          style: TextStyle(
                            color: tokens.cyan,
                            fontSize: compact ? 8 : 9,
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
                    onPressed: onRemove,
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
                  fontSize: 9,
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
  const _GameModeRail({required this.compact, required this.onSelectGame});
  final bool compact;
  final ValueChanged<String> onSelectGame;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final l10n = AppLocalizations.of(context)!;
    const games = <(String, String, String)>[
      ('quiz', 'quiz', 'TEST YOUR KNOWLEDGE'),
      ('word_play', 'wordPlay', 'BUILD WORDS, SCORE BIG'),
      ('guessing_games', 'guessingGames', 'CHARACTER + COUNTRY CHALLENGES'),
    ];
    return Row(
      children: <Widget>[
        for (var index = 0; index < games.length; index++) ...<Widget>[
          if (index > 0) SizedBox(width: compact ? 4 : 8),
          Expanded(
            child: Material(
              color: const Color(0xBC071426),
              child: InkWell(
                onTap: () => onSelectGame(games[index].$1),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _GameModeArtwork(
                      gameId: games[index].$1 == 'guessing_games'
                          ? 'guess_character'
                          : games[index].$1,
                    ),
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
                              games[index].$1 == 'guessing_games'
                                  ? 'GUESSING GAMES'
                                  : _gameTitle(
                                      l10n,
                                      games[index].$2,
                                    ).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 12 : 15,
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
                                games[index].$3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
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
                      height: compact ? 3 : 4,
                      child: ColoredBox(color: tokens.orange),
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
