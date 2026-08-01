import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/word_timing.dart';

/// Result of opening a .audity bundle: a playable local mp3 path, plus the
/// parsed transcript/timestamps that go with it.
class OpenedAudityFile {
  final String audioFilePath;
  final TranscriptData transcript;

  const OpenedAudityFile({
    required this.audioFilePath,
    required this.transcript,
  });
}

class AudityParser {
  /// Unzips [audityFilePath] into a per-file subfolder under the app's
  /// support directory, then reads audio.mp3 + timestamps.json out of it.
  ///
  /// Re-extraction is skipped if the target folder already exists and
  /// already contains both expected files -- so re-opening the same file
  /// twice is fast.
  static Future<OpenedAudityFile> open(String audityFilePath) async {
    final bytes = await File(audityFilePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final supportDir = await getApplicationSupportDirectory();
    final baseName = p.basenameWithoutExtension(audityFilePath);
    // Include a short hash of the path so two different files with the
    // same display name don't collide.
    final key = '${baseName}_${audityFilePath.hashCode.toRadixString(16)}';
    final extractDir = Directory(p.join(supportDir.path, 'audity_cache', key));

    final audioOut = File(p.join(extractDir.path, 'audio.mp3'));
    final timestampsOut = File(p.join(extractDir.path, 'timestamps.json'));

    final alreadyExtracted = await audioOut.exists() && await timestampsOut.exists();

    if (!alreadyExtracted) {
      await extractDir.create(recursive: true);

      for (final entry in archive) {
        if (!entry.isFile) continue;
        final outPath = p.join(extractDir.path, entry.name);
        final outFile = File(outPath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(entry.content as List<int>);
      }

      if (!await audioOut.exists() || !await timestampsOut.exists()) {
        throw const FormatException(
          'This .audity file is missing audio.mp3 or timestamps.json -- '
          'it may be corrupted or made by a different version.',
        );
      }
    }

    final timestampsRaw = await timestampsOut.readAsString();
    final transcript = TranscriptData.fromJson(
      jsonDecode(timestampsRaw) as Map<String, dynamic>,
    );

    return OpenedAudityFile(
      audioFilePath: audioOut.path,
      transcript: transcript,
    );
  }
}
