import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/audity_file.dart';

const _kExtraFoldersPrefKey = 'audity_extra_scan_folders';

class FileScanner {
  /// Best-effort guess at the platform's Downloads folder.
  /// - Windows: %USERPROFILE%\Downloads
  /// - Android: /storage/emulated/0/Download (the conventional shared path;
  ///   not guaranteed on every OEM/Android version, which is exactly why
  ///   "add a folder" exists as a fallback below).
  static Future<Directory?> defaultDownloadsDir() async {
    if (Platform.isWindows) {
      final home = Platform.environment['USERPROFILE'];
      if (home == null) return null;
      final dir = Directory('$home\\Downloads');
      return dir.existsSync() ? dir : null;
    }

    if (Platform.isAndroid) {
      const path = '/storage/emulated/0/Download';
      final dir = Directory(path);
      return dir.existsSync() ? dir : null;
    }

    return null;
  }

  /// On Android 11+, broad filesystem access needs MANAGE_EXTERNAL_STORAGE,
  /// which Google Play restricts to apps whose *core* function needs it.
  /// A player scanning for user files plausibly qualifies, but it's still
  /// worth trying the narrower `Permission.storage` / scoped access first
  /// and only falling back to this if the user actively picks folders
  /// outside the default Downloads path. See PLAYER_README.md.
  static Future<bool> ensureAndroidPermission() async {
    if (!Platform.isAndroid) return true;

    var status = await Permission.storage.status;
    if (status.isGranted) return true;

    status = await Permission.storage.request();
    if (status.isGranted) return true;

    // Older narrow permission wasn't granted (likely Android 11+ scoped
    // storage) -- try the broader one. This will prompt the user through
    // a system settings screen, not an in-app dialog.
    final manageStatus = await Permission.manageExternalStorage.request();
    return manageStatus.isGranted;
  }

  static Future<List<String>> _loadExtraFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kExtraFoldersPrefKey) ?? [];
  }

  static Future<void> _saveExtraFolders(List<String> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kExtraFoldersPrefKey, folders);
  }

  /// Opens a native folder picker and remembers the choice for future scans.
  static Future<String?> addFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose a folder to scan for .audity files',
    );
    if (path == null) return null;

    final folders = await _loadExtraFolders();
    if (!folders.contains(path)) {
      folders.add(path);
      await _saveExtraFolders(folders);
    }
    return path;
  }

  static Future<List<String>> extraFolders() => _loadExtraFolders();

  static Future<void> removeFolder(String path) async {
    final folders = await _loadExtraFolders();
    folders.remove(path);
    await _saveExtraFolders(folders);
  }

  /// Scans the default Downloads folder (if found) plus any user-added
  /// folders, non-recursively per folder (kept flat and fast -- most people
  /// will just have these sitting loose in Downloads).
  static Future<List<AudityFile>> scan() async {
    await ensureAndroidPermission();

    final foldersToScan = <Directory>[];

    final downloads = await defaultDownloadsDir();
    if (downloads != null) foldersToScan.add(downloads);

    for (final path in await _loadExtraFolders()) {
      final dir = Directory(path);
      if (await dir.exists()) foldersToScan.add(dir);
    }

    final results = <AudityFile>[];
    final seenPaths = <String>{};

    for (final dir in foldersToScan) {
      List<FileSystemEntity> entries;
      try {
        entries = await dir.list().toList();
      } catch (_) {
        // Permission denied or folder disappeared mid-scan -- skip it
        // rather than crashing the whole scan.
        continue;
      }

      for (final entity in entries) {
        if (entity is! File) continue;
        final lowerPath = entity.path.toLowerCase();
        final isAudityFile = lowerPath.endsWith('.audity') || lowerPath.endsWith('.audity.zip');
        if (!isAudityFile) continue;
        if (!seenPaths.add(entity.path)) continue;

        results.add(await AudityFile.fromFile(entity));
      }
    }

    results.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return results;
  }
}
