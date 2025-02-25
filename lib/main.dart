import 'dart:io';

import 'package:flutter/widgets.dart';

void main() {
  const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'full');

  if (flavor == 'full') {
    WidgetsFlutterBinding.ensureInitialized(); // ✅ เพิ่มบรรทัดนี้
    Future.delayed(Duration.zero, () {
      runFull();
    });
  } else if (flavor == 'test') {
    Future.delayed(Duration.zero, () {
      runTest();
    });
  } else {
    throw UnsupportedError("Flavor '$flavor' is not supported.");
  }
}

void runFull() {
  print("Running Full Version");
  Process.run('flutter', ['run', '--target=lib/main_full.dart']);
}

void runTest() {
  print("Running Test Version");
  Process.run('flutter', ['run', '--target=lib/main_level1.dart']);
}
