import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveBytes(List<int> bytes, String filename) async {
  final blob = html.Blob(<Object>[Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();

  await Future<void>.delayed(const Duration(milliseconds: 100));
  html.Url.revokeObjectUrl(url);
}
