import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DownloadUtils {
  DownloadUtils._();

  /// Saves or opens a downloaded file.
  ///
  /// On web, the browser handles the download.
  /// On mobile/desktop, this method delegates to the platform-specific
  /// implementation available to the application.
  static Future<void> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError(
        'Cannot save an empty file.',
      );
    }

    if (fileName.trim().isEmpty) {
      throw ArgumentError(
        'A file name is required.',
      );
    }

    if (kIsWeb) {
      _downloadOnWeb(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      return;
    }

    throw UnsupportedError(
      'Direct file saving must be implemented using '
      'the platform file/download integration.',
    );
  }

  /// Downloads an Excel report.
  static Future<void> saveExcel({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final normalizedName =
        fileName.toLowerCase().endsWith('.xlsx')
            ? fileName
            : '$fileName.xlsx';

    await saveFile(
      bytes: bytes,
      fileName: normalizedName,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  /// Downloads a PDF report.
  static Future<void> savePdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final normalizedName =
        fileName.toLowerCase().endsWith('.pdf')
            ? fileName
            : '$fileName.pdf';

    await saveFile(
      bytes: bytes,
      fileName: normalizedName,
      mimeType: 'application/pdf',
    );
  }

  /// Opens/saves arbitrary report bytes according to their MIME type.
  static Future<void> saveReport({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    await saveFile(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  static void _downloadOnWeb({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    // `dart:html` is intentionally avoided here so the shared application
    // layer remains compatible with non-web Flutter targets.
    //
    // The actual web download should be connected through the project's
    // platform-specific implementation.
    throw UnsupportedError(
      'Web download integration is not configured.',
    );
  }

  /// Creates a safe filename from user-provided text.
  static String sanitizeFileName(
    String fileName, {
    String fallback = 'download',
  }) {
    final trimmed = fileName.trim();

    if (trimmed.isEmpty) {
      return fallback;
    }

    final sanitized = trimmed.replaceAll(
      RegExp(r'[<>:"/\\|?*\x00-\x1F]'),
      '_',
    );

    return sanitized.isEmpty ? fallback : sanitized;
  }

  /// Adds a file extension only when it is missing.
  static String ensureExtension(
    String fileName,
    String extension,
  ) {
    final normalizedFileName =
        fileName.trim();

    var normalizedExtension =
        extension.trim();

    if (normalizedFileName.isEmpty) {
      return 'download$normalizedExtension';
    }

    if (normalizedExtension.isEmpty) {
      return normalizedFileName;
    }

    if (!normalizedExtension.startsWith('.')) {
      normalizedExtension = '.$normalizedExtension';
    }

    if (normalizedFileName
        .toLowerCase()
        .endsWith(normalizedExtension.toLowerCase())) {
      return normalizedFileName;
    }

    return '$normalizedFileName$normalizedExtension';
  }

  /// Generates a conventional report filename.
  static String reportFileName({
    required String prefix,
    String? identifier,
    String? extension,
  }) {
    final parts = <String>[
      sanitizeFileName(prefix),
    ];

    if (identifier != null &&
        identifier.trim().isNotEmpty) {
      parts.add(
        sanitizeFileName(identifier),
      );
    }

    var result = parts.join('_');

    if (extension != null &&
        extension.trim().isNotEmpty) {
      result = ensureExtension(
        result,
        extension,
      );
    }

    return result;
  }

  /// Shows a consistent success message after a download.
  static void showDownloadSuccess(
    BuildContext context, {
    required String fileName,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$fileName downloaded successfully.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a consistent failure message for report downloads.
  static void showDownloadError(
    BuildContext context, {
    String message =
        'Unable to download the file. Please try again.',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}