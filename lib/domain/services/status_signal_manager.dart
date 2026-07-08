import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';

/// Base class representing environmental signals capable of triggering evaluation.
abstract class StatusSignal extends Equatable {
  const StatusSignal();

  @override
  List<Object?> get props => [];
}

class PassiveStreamingSignal extends StatusSignal {
  final String eventType;
  const PassiveStreamingSignal(this.eventType);
  @override
  List<Object?> get props => [eventType];
}

class ActivePollingSignal extends StatusSignal {
  const ActivePollingSignal();
}

/// Adaptive stream coordinator that manages hardware telemetry polling
/// and passive WebScoket streaming to optimize network and battery footprints.
class StatusSignalManager {
  final VrchatDart _vrcApi;
  final StreamController<StatusSignal> _controller = StreamController<StatusSignal>.broadcast();

  Timer? _pollingTimer;
  StreamSubscription? _streamSubscription;

  StatusSignalManager(this._vrcApi);

  Stream<StatusSignal> get signals => _controller.stream;

  void setupSignalsForProfile(StatusProfile profile) {
    _shutdown();

    final bool requiresActivePolling = profile.rules.any((rule) =>
      rule.conditionType == ConditionType.batteryLevel ||
      rule.conditionType == ConditionType.timeRange
      ) || profile.fallbackTemplate?.contains('{{battery}}') == true 
        || profile.fallbackTemplate?.contains('{{time}}') == true;
    
    _streamSubscription = _vrcApi.streaming.vrcEventStream.listen((event) {
      if (event is UserUpdateEvent) {
        _controller.add(const PassiveStreamingSignal('UserUpdateEvent'));
      } else if (event is UserLocationEvent) {
        _controller.add(const PassiveStreamingSignal('UserLocationEvenet'));
      }
    }, onError: (err) {
      debugPrint("StatusSignalManager Streaming Error: $err");
    });

    if (requiresActivePolling) {
      debugPrint("StatusSignalManager: Active Polling started (Battery/Time rule detected)");
      _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        _controller.add(const ActivePollingSignal());
      });
    } else {
      debugPrint("StatusSignalManager: Running strictly in Passive (Event-Driven) Mode");
    }
  }

  void dispose() {
    _shutdown();
    _controller.close();
  }

  void _shutdown() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}