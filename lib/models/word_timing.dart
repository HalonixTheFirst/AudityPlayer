/// Mirrors one entry in the "words" array of timestamps.json, produced by
/// the Audity backend's merger.py. Field names match exactly so JSON
/// decoding needs no remapping.
class WordTiming {
  final String word;
  final int startTimeMs;
  final int endTimeMs;

  const WordTiming({
    required this.word,
    required this.startTimeMs,
    required this.endTimeMs,
  });

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: json['word'] as String,
      startTimeMs: (json['start_time_ms'] as num).toInt(),
      endTimeMs: (json['end_time_ms'] as num).toInt(),
    );
  }
}

/// The full parsed contents of a .audity file's timestamps.json.
class TranscriptData {
  final String fullText;
  final int durationMs;
  final List<WordTiming> words;

  const TranscriptData({
    required this.fullText,
    required this.durationMs,
    required this.words,
  });

  factory TranscriptData.fromJson(Map<String, dynamic> json) {
    final wordsJson = (json['words'] as List<dynamic>? ?? []);
    return TranscriptData(
      fullText: json['full_text'] as String? ?? '',
      durationMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
      words: wordsJson
          .map((w) => WordTiming.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Index of the word that should be considered "active" at [positionMs],
  /// or -1 if we're before the first word / after the last / in a gap.
  int activeWordIndexAt(int positionMs) {
    // -1 only when we're before the very first word. Once narration has
    // started, a silent gap between words keeps the last-finished word
    // "active" (rather than snapping back to no-highlight) so the fade
    // doesn't flash to a flat, washed-out state during pauses.
    int lastPassedIndex = -1;

    for (var i = 0; i < words.length; i++) {
      if (positionMs >= words[i].startTimeMs &&
          positionMs < words[i].endTimeMs) {
        return i; // currently inside this word
      }
      if (positionMs >= words[i].endTimeMs) {
        lastPassedIndex = i; // this word has already finished
      } else {
        break; // words are in order; no need to scan further
      }
    }

    return lastPassedIndex;
  }
}