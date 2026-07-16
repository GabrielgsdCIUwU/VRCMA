/// Interactions with VRChat groups calendar web API.
abstract class IRemoteCalendarRepository {
  Future<bool> verifyCreationPermissions(String userId, String groupId);

  Future<String> createEvent(
    String groupId,
    String title,
    DateTime startUtc,
    DateTime endUtc,
    String desc,
    Map<String, dynamic> options,
  );

  Future<void> deleteEvent(String groupId, String eventId);
}