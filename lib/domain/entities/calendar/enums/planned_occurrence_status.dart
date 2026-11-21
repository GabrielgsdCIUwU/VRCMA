/// Represents the evaluation state of a calculated future calendar slot.
enum PlannedOccurrenceStatus {
  /// No matching local run or remote VRChat event was found; ready to publish.
  pendingPublish,

  /// Already covered by an active local run or an existing event on VRChat.
  alreadyPublished,

  /// Explicitly skipped due to a matching cancellation exception.
  cancelledByException,
}