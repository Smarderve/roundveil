import 'package:flutter/material.dart';

class ArenaBackdrop extends StatelessWidget {
  const ArenaBackdrop({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFE8EDF4), Color(0xFFD6E3F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Stack(
      children: [
        const Positioned(
          top: -100,
          right: -130,
          child: _ArenaOrb(color: Color(0x332879BA), size: 340),
        ),
        const Positioned(
          bottom: -140,
          left: -100,
          child: _ArenaOrb(color: Color(0x33F4A62C), size: 320),
        ),
        SafeArea(child: child),
      ],
    ),
  );
}

class _ArenaOrb extends StatelessWidget {
  const _ArenaOrb({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.42,
    child: Container(width: size, height: size, color: color),
  );
}

class ArenaButton extends StatelessWidget {
  const ArenaButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Transform(
      transform: Matrix4.skewX(-.12),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: secondary
              ? const Color(0xFFF8FBFF)
              : const Color(0xFFF4A62C),
          foregroundColor: const Color(0xFF263449),
          side: BorderSide(
            color: secondary
                ? const Color(0xFF2879BA)
                : const Color(0xFF263449),
            width: 2,
          ),
          minimumSize: const Size(150, 52),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: onPressed,
        child: Transform(
          transform: Matrix4.skewX(.12),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ),
      ),
    ),
  );
}

class ArenaChoice extends StatelessWidget {
  const ArenaChoice({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF263449),
      backgroundColor: selected
          ? const Color(0xFFDBEBF9)
          : const Color(0xFFF8FBFF),
      side: BorderSide(
        color: selected ? const Color(0xFF2879BA) : const Color(0xFFA3B5C6),
        width: selected ? 3 : 1.5,
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      minimumSize: const Size(74, 48),
    ),
    onPressed: onPressed,
    child: Text(label, textAlign: TextAlign.center),
  );
}

class ArenaHeader extends StatelessWidget {
  const ArenaHeader({required this.kicker, required this.title, super.key});
  final String kicker;
  final String title;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        kicker.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF2879BA),
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF263449),
          fontSize: 30,
          height: .95,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
    ],
  );
}
