/// Model class for tracking a single intervention session.
///
/// This class stores the before and after metrics of a breathing intervention,
/// including the overload scores, timing information, and user mood.
class InterventionSession {
  /// Overload score before the intervention
  double preScore;

  /// Overload score after the intervention (set when session completes)
  double? postScore;

  /// Timestamp when the intervention started
  DateTime startTime;

  /// Timestamp when the intervention completed (set when session completes)
  DateTime? endTime;

  /// User's self-reported mood after the intervention (optional)
  String? mood;

  /// Creates a new InterventionSession with the pre-intervention score.
  ///
  /// The session is initialized with the current overload score and start time.
  /// postScore, endTime, and mood are set later when the session completes.
  ///
  /// Requirements: 6.2, 7.1
  InterventionSession({
    required this.preScore,
    required this.startTime,
  });

  /// Completes the intervention session with post-intervention data.
  ///
  /// Records the final overload score, completion time, and optional mood.
  ///
  /// Parameters:
  /// - postScore: The overload score after the intervention
  /// - mood: Optional user-selected mood (e.g., "happy", "neutral", "sad")
  ///
  /// Requirements: 7.2
  void complete(double postScore, String? mood) {
    this.postScore = postScore;
    this.endTime = DateTime.now();
    this.mood = mood;
  }

  /// Calculates the percentage reduction in overload score.
  ///
  /// Returns the percentage decrease from pre-intervention to post-intervention
  /// score. For example, if preScore is 80 and postScore is 40, this returns 50.0.
  ///
  /// Returns 0.0 if postScore is not set (session not completed).
  ///
  /// Requirements: 7.4
  double getReductionPercentage() {
    if (postScore == null) {
      return 0.0;
    }
    return ((preScore - postScore!) / preScore) * 100;
  }
}
