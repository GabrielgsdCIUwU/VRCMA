import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

part 'calendar_scheduler_provider.g.dart';

@riverpod
class CalendarScheduler extends _$CalendarScheduler {
  Timer? _evaluationTimer; 
  static const Duration _evaluationInterval = Duration(minutes: 30);

  @override
  void build() {
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        _startScheduler();
      } else {
        _stopScheduler();
      }
    });

    ref.onDispose(() {
      _stopScheduler();
    });

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      _startScheduler();
    }
  }

  void _startScheduler() {
    _stopScheduler();
    evaluateNow();
    _evaluationTimer = Timer.periodic(_evaluationInterval, (_) => evaluateNow());
  }

  void _stopScheduler() {
    _evaluationTimer?.cancel();
    _evaluationTimer = null;
  }

  void evaluateNow() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      final useCase = await ref.read(evaluateAndGenerateEventsUseCaseProvider.future);
      await useCase.execute(hostUser: user);
    } catch (e, stack) {
      debugPrint('Calendar evaluation cycle failed: $e\n$stack');
    }
  }
}