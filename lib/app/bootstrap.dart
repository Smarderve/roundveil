import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roundveil/app/roundveil_app.dart';

void bootstrapRoundveil() {
  runApp(const ProviderScope(child: RoundveilApp()));
}
