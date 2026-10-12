import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brief, fullscreen presentation of the supplied official ROUNDVEIL lockup.
class BrandedOpeningScreen extends StatefulWidget {
  const BrandedOpeningScreen({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<BrandedOpeningScreen> createState() => _BrandedOpeningScreenState();
}

class _BrandedOpeningScreenState extends State<BrandedOpeningScreen> {
  Timer? _finishTimer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _setSystemUi(fullscreen: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
      _finishTimer = Timer(const Duration(milliseconds: 1150), () {
        if (!mounted) return;
        _setSystemUi(fullscreen: false);
        widget.onFinished();
      });
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _setSystemUi(fullscreen: false);
    super.dispose();
  }

  void _setSystemUi({required bool fullscreen}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF05030D),
    body: SizedBox.expand(
      child: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160, maxHeight: 720),
              child: Image.asset(
                'assets/brand/roundveil_logo_lockup.webp',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                semanticLabel: 'ROUNDVEIL official logo and mascot',
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
