import 'dart:io';

/// A .audity file found on disk, before it's been opened/extracted.
class AudityFile {
  final String path;
  final String displayName;
  final DateTime modifiedAt;
  final int sizeBytes;

  const AudityFile({
    required this.path,
    required this.displayName,
    required this.modifiedAt,
    required this.sizeBytes,
  });

  static Future<AudityFile> fromFile(File file) async {
    final stat = await file.stat();
    final name = file.uri.pathSegments.last.replaceAll(RegExp(r'\.audity(\.zip)?$'), '');    return AudityFile(
      path: file.path,
      displayName: name,
      modifiedAt: stat.modified,
      sizeBytes: stat.size,
    );
  }

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
