import 'package:flutter/material.dart';
import '../theme.dart';

String _formatTime(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

class PlaybackControls extends StatelessWidget {
  final bool playing;
  final Duration position;
  final Duration duration;
  final double speed;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<double> onSpeedChange;

  const PlaybackControls({
    super.key,
    required this.playing,
    required this.position,
    required this.duration,
    required this.speed,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSpeedChange,
  });

  static const _speedOptions = [0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.clamp(0, maxMs == 0 ? 0 : maxMs.toInt()).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PlayButton(playing: playing, onTap: onPlayPause),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  min: 0,
                  max: maxMs == 0 ? 1 : maxMs,
                  value: maxMs == 0 ? 0 : posMs,
                  onChanged: (v) => onSeek(Duration(milliseconds: v.round())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(position),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        color: AudityColors.inkMuted,
                      ),
                    ),
                    Text(
                      _formatTime(duration),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        color: AudityColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _SpeedDropdown(
          value: speed,
          options: _speedOptions,
          onChanged: onSpeedChange,
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool playing;
  final VoidCallback onTap;

  const _PlayButton({required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AudityColors.teal,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            playing ? Icons.pause : Icons.play_arrow,
            color: AudityColors.bg,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SpeedDropdown extends StatelessWidget {
  final double value;
  final List<double> options;
  final ValueChanged<double> onChanged;

  const _SpeedDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AudityColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AudityColors.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: value,
          dropdownColor: AudityColors.surfaceRaised,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12.5,
            color: AudityColors.ink,
          ),
          items: options
              .map((s) => DropdownMenuItem(value: s, child: Text('${s}x')))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
