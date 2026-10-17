/// Returns the largest no-repeat Picture Mode round count this lobby can play.
///
/// Quick Game normally uses four rounds. A smaller image pool reduces the
/// match to the number of complete, distinct rounds supported by every player;
/// it never repeats a picture or silently changes the selected category.
int pictureModeRoundCapacity({
  required int imageCount,
  required int playerCount,
  int requestedRounds = 4,
}) {
  if (imageCount <= 0 || playerCount <= 0 || requestedRounds <= 0) return 0;
  return (imageCount ~/ playerCount).clamp(0, requestedRounds);
}
