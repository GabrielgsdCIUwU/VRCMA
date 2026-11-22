import 'package:flutter/rendering.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/usecases/automation/handlers/automation_handler.dart';

class AutomationProcessor {
  final List<AutomationEventHandler> _handlers;

  
  AutomationProcessor(this._handlers);
  
  Future<void> process(VrcAutomationEvent event) async {
    for (final handler in _handlers) {
      if (handler.canHandle(event)) {
        try {
          await handler.handle(event);
        } catch (e, stackTrace) {
          debugPrint("Error handling event ${event.runtimeType}: $e\n$stackTrace");
        }
      }
    }
  }
}