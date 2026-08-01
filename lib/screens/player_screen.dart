import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/audity_file.dart';
import '../models/word_timing.dart';
import '../services/audity_parser.dart';
import '../theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/fading_transcript.dart';
import '../widgets/playback_controls.dart';

class PlayerScreen extends StatefulWidget {
  final AudityFile file;

  const PlayerScreen({super.key, required this.file});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();

  TranscriptData? _transcript;
  String? _loadError;
  int _activeWordIndex = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final opened = await AudityParser.open(widget.file.path);
      await _player.setFilePath(opened.audioFilePath);

      setState(() => _transcript = opened.transcript);

      _player.positionStream.listen((pos) {
        final t = _transcript;
        if (t == null) return;
        final idx = t.activeWordIndexAt(pos.inMilliseconds);
        if (idx != _activeWordIndex) {
          setState(() => _activeWordIndex = idx);
        }
      });
    } catch (e) {
      setState(() => _loadError = e.toString());
    }
  }

  void _seekToWord(int index) {
    final t = _transcript;
    if (t == null || index < 0 || index >= t.words.length) return;
    _player.seek(Duration(milliseconds: t.words[index].startTimeMs));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AudityLogo(fontSize: 22),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loadError != null
              ? _ErrorState(message: _loadError!)
              : _transcript == null
                  ? const Center(child: CircularProgressIndicator(color: AudityColors.brass))
                  : _PlayerBody(
                      file: widget.file,
                      transcript: _transcript!,
                      player: _player,
                      activeWordIndex: _activeWordIndex,
                      onWordTap: _seekToWord,
                    ),
        ),
      ),
    );
  }
}

class _PlayerBody extends StatelessWidget {
  final AudityFile file;
  final TranscriptData transcript;
  final AudioPlayer player;
  final int activeWordIndex;
  final ValueChanged<int> onWordTap;

  const _PlayerBody({
    required this.file,
    required this.transcript,
    required this.player,
    required this.activeWordIndex,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The big transcript card -- matches the rounded gray panel in the blueprint.
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AudityColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AudityColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: FadingTranscript(
              words: transcript.words,
              activeIndex: activeWordIndex,
              onWordTap: onWordTap,
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          file.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12.5,
            color: AudityColors.inkMuted,
          ),
        ),
        const SizedBox(height: 14),

        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, posSnap) {
            return StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, stateSnap) {
                final playing = stateSnap.data?.playing ?? false;
                final duration = player.duration ?? Duration.zero;
                final position = posSnap.data ?? Duration.zero;

                return PlaybackControls(
                  playing: playing,
                  position: position,
                  duration: duration,
                  speed: player.speed,
                  onPlayPause: () {
                    if (playing) {
                      player.pause();
                    } else {
                      player.play();
                    }
                  },
                  onSeek: (d) => player.seek(d),
                  onSpeedChange: (s) => player.setSpeed(s),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AudityColors.danger, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AudityColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
