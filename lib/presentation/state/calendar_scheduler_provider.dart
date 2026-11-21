import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/calendar_automation_provider.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';

part 'calendar_scheduler_provider.g.dart';

/// Coordinates periodic and on-demand evaluation of active calendar rules.
///
/// Exposes `true` while an evaluation pass is running so the UI can show progress.
@Riverpod(keepAlive: true)
class CalendarScheduler extends _$CalendarScheduler {
  static const Duration _evaluationInterval = Duration(minutes: 30);

  Timer? _evaluationTimer;

  @override
  bool build() {
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        _startScheduler();
      } else {
        _stopScheduler();
      }
    });

    ref.onDispose(_stopScheduler);

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      _startScheduler();
    }

    return false;
  }

  void _startScheduler() {
    _stopScheduler();
    // Defer initial evaluation until build() finishes initializing provider state.
    Future.microtask(evaluateNow);
    _evaluationTimer =
        Timer.periodic(_evaluationInterval, (_) => evaluateNow());
  }

  void _stopScheduler() {
    _evaluationTimer?.cancel();
    _evaluationTimer = null;
  }

  /// Runs a calendar evaluation pass immediately if none is currently active.
  Future<void> evaluateNow() async {
    if (!ref.mounted || state) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = true;
    try {
      final useCase =
      await ref.read(evaluateAndGenerateEventsUseCaseProvider.future);
      await useCase.execute(hostUser: user);
      if (ref.mounted) _refreshCalendarDependents();
    } catch (error, stack) {
      debugPrint('Calendar evaluation cycle failed: $error\n$stack');
    } finally {
      if (ref.mounted) state = false;
    }
  }

  void _refreshCalendarDependents() {
    ref.invalidate(calendarAutomationListProvider);
    ref.invalidate(groupUpcomingEventsProvider);
    ref.invalidate(appLogsProvider);
  }
}