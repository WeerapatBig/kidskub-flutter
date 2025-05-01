import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import 'main_full.dart' as full;
import 'main_kidskubdebug.dart' as debug;

void main() {
  const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'full');

  WidgetsFlutterBinding.ensureInitialized(); // ✅ ใส่ให้ชัวร์ก่อน runApp

  if (kIsWeb) {
    // ✅ บนเว็บ ให้รัน full ไปเลย (หรือเปลี่ยนตามต้องการ)
    full.main();
  } else if (flavor == 'full') {
    full.main();
  } else if (flavor == 'test') {
    debug.main(); // หรือจะเป็น main_level1 ก็ได้ ถ้าคุณมี
  } else {
    throw UnsupportedError("Flavor '$flavor' is not supported.");
  }
}
