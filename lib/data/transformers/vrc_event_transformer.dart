import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrchat_dart/vrchat_dart.dart';


abstract class VrcEventTransformer<T extends VrcAutomationEvent> {
  /// Determines if this transformer can map the incoming streaming event.
  bool canHandle(VrcStreamingEvent event);

  /// Converts the raw streaming event into a clean domain automation event.
  Future<T?> transform(
    VrcStreamingEvent event,
    Future<User?> Function(String userId) getEnrichedUser,
  );
}