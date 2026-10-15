import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays a bundled, silent video asset and releases its native player when
/// removed. The caller supplies the still-art fallback for missing/unavailable
/// clips, so a failed asset never leaves a black or misleading character slot.
class OfflineLoopingVideo extends StatefulWidget {
  const OfflineLoopingVideo({
    required this.assetPath,
    required this.fallback,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? assetPath;
  final Widget fallback;
  final BoxFit fit;

  @override
  State<OfflineLoopingVideo> createState() => _OfflineLoopingVideoState();
}

class _OfflineLoopingVideoState extends State<OfflineLoopingVideo>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didUpdateWidget(covariant OfflineLoopingVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      final previous = _controller;
      _controller = null;
      _error = null;
      if (previous != null) unawaited(previous.dispose());
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final assetPath = widget.assetPath;
    if (assetPath == null || assetPath.isEmpty) return;
    // video_player_win's unsigned native DLL is rejected by this host's
    // Enterprise Application Control policy. Keep Windows on the supplied
    // still-art fallback until an organization-approved signed backend exists.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) return;
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
      setState(
        () => _error = UnsupportedError(
          'Character video playback is supported only on Android and Windows.',
        ),
      );
      return;
    }

    final controller = VideoPlayerController.asset(assetPath);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted || !identical(_controller, controller)) return;
      await controller.play();
      if (mounted && identical(_controller, controller)) setState(() {});
    } on Object catch (error) {
      debugPrint('ROUNDVEIL video asset failed ($assetPath): $error');
      if (!mounted || !identical(_controller, controller)) return;
      _error = error;
      await controller.dispose();
      _controller = null;
      if (mounted) setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(controller.pause());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(controller.play());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_error != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return widget.fallback;
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: FittedBox(
        fit: widget.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
