import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> saveCertificate(Uint8List pngBytes, String name) async {
  Directory dir;
  try {
    dir = await getApplicationDocumentsDirectory();
  } catch (_) {
    dir = Directory(path.join(Platform.environment['USERPROFILE'] ?? '', 'Downloads'));
  }
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final file = File(path.join(dir.path, '${_sanitize(name)}-certificate.png'));
  await file.writeAsBytes(pngBytes);
}

String _sanitize(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9._ -]+'), '_');


