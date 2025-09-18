import 'dart:typed_data';
import 'dart:html' as html;

Future<void> saveCertificate(Uint8List pngBytes, String name) async {
  final blob = html.Blob([pngBytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = '${_sanitize(name)}-certificate.png'
    ..click();
  html.Url.revokeObjectUrl(url);
}

String _sanitize(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9._ -]+'), '_');





