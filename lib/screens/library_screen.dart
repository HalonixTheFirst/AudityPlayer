import 'package:flutter/material.dart';

import '../models/audity_file.dart';
import '../services/file_scanner.dart';
import '../theme.dart';
import '../widgets/app_logo.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<AudityFile> _files = [];
  bool _scanning = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final files = await FileScanner.scan();
      setState(() {
        _files = files;
        _scanning = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not scan for files: $e';
        _scanning = false;
      });
    }
  }

  Future<void> _addFolder() async {
    final path = await FileScanner.addFolder();
    if (path != null) _scan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AudityLogo(fontSize: 22),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Add a folder to scan',
            onPressed: _addFolder,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rescan',
            onPressed: _scan,
          ),
        ],
      ),
      body: SafeArea(
        child: _scanning
            ? const Center(child: CircularProgressIndicator(color: AudityColors.brass))
            : _error != null
                ? _EmptyState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    subtitle: _error!,
                    onAddFolder: _addFolder,
                  )
                : _files.isEmpty
                    ? _EmptyState(
                        icon: Icons.library_music_outlined,
                        title: 'No .audity files found yet',
                        subtitle:
                            'We looked in your Downloads folder. If your file is somewhere else, add that folder below.',
                        onAddFolder: _addFolder,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _files.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final file = _files[i];
                          return _AudityListTile(
                            file: file,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(file: file),
                                ),
                              );
                            },
                          );
                        },
                      ),
      ),
    );
  }
}

class _AudityListTile extends StatelessWidget {
  final AudityFile file;
  final VoidCallback onTap;

  const _AudityListTile({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AudityColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AudityColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AudityColors.brassSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.graphic_eq, color: AudityColors.brass, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: AudityColors.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      file.sizeLabel,
                      style: const TextStyle(fontSize: 12, color: AudityColors.inkMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AudityColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAddFolder;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAddFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AudityColors.inkMuted, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AudityColors.ink),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AudityColors.inkMuted),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAddFolder,
              icon: const Icon(Icons.create_new_folder_outlined, size: 18),
              label: const Text('Add a folder'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AudityColors.brass,
                side: const BorderSide(color: AudityColors.brass),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
