import 'package:flutter/material.dart';
import '../models/word_timing.dart';
import '../theme.dart';

/// Renders the whole transcript with a "spotlight" fade centered on the
/// active word: opacity is 1.0 at the active word and falls off with
/// distance in both directions, floored so far-away words are still
/// faintly legible rather than invisible.
class FadingTranscript extends StatefulWidget {
  final List<WordTiming> words;
  final int activeIndex;
  final ValueChanged<int> onWordTap;

  const FadingTranscript({
    super.key,
    required this.words,
    required this.activeIndex,
    required this.onWordTap,
  });

  @override
  State<FadingTranscript> createState() => _FadingTranscriptState();
}

class _FadingTranscriptState extends State<FadingTranscript> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _wordKeys = {};

  GlobalKey _keyFor(int index) => _wordKeys.putIfAbsent(index, () => GlobalKey());

  @override
  void didUpdateWidget(covariant FadingTranscript oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex && widget.activeIndex >= 0) {
      _scrollToActiveWord();
    }
  }

  void _scrollToActiveWord() {
    // Wait a frame so the widget tree reflects the new active index first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _wordKeys[widget.activeIndex];
      final context = key?.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  double _opacityFor(int index) {
    if (widget.activeIndex < 0) return 0.55;
    final distance = (index - widget.activeIndex).abs();
    if (distance == 0) return 1.0;
    // Falls from 1.0 toward a floor of 0.18, ~6 words out in either direction.
    final raw = 1.0 - (distance * 0.15);
    return raw.clamp(0.18, 1.0);
  }

  FontWeight _weightFor(int index) {
    return index == widget.activeIndex ? FontWeight.w600 : FontWeight.w400;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(28),
      child: Wrap(
        spacing: 6,
        runSpacing: 10,
        children: List.generate(widget.words.length, (i) {
          final w = widget.words[i];
          return GestureDetector(
            key: _keyFor(i),
            onTap: () => widget.onWordTap(i),
            child: AnimatedOpacity(
              opacity: _opacityFor(i),
              duration: const Duration(milliseconds: 180),
              child: Text(
                w.word,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.5,
                  color: AudityColors.ink,
                  fontWeight: _weightFor(i),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
