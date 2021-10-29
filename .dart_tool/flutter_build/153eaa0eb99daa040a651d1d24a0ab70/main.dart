// @dart=2.14

import 'dart:ui' as ui;

import 'package:tkd_terms/main.dart' as entrypoint;

Future<void> main() async {
  await ui.webOnlyInitializePlatform();
  entrypoint.main();
}
