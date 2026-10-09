import 'package:flutter/widgets.dart';

enum RoundveilLayoutClass { compact, expanded }

abstract final class RoundveilResponsiveLayout {
  static RoundveilLayoutClass forConstraints(BoxConstraints constraints) {
    return constraints.maxWidth < 600
        ? RoundveilLayoutClass.compact
        : RoundveilLayoutClass.expanded;
  }
}
