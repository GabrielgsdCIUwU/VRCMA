import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';

part 'world_cache_provider.g.dart';

class _WorldConcurrencyLock {
  int _active = 0;
  final int maxConcurrent;
  final List<Completer<void>> _queue = [];

  _WorldConcurrencyLock(this.maxConcurrent);

  Future<void> acquire() async {
    if (_active < maxConcurrent) {
      _active++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    return completer.future;
  }

  void release() {
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      next.complete();
    } else {
      _active--;
    }
  }
}

final _worldFetchLock = _WorldConcurrencyLock(3);

@Riverpod(keepAlive: true)
Future<String> worldName(Ref ref, String worldId) async {
  if (worldId.isEmpty || !worldId.startsWith('wrld_')) return "Unknown World";

  await _worldFetchLock.acquire();

  try {
    final repo = await ref.watch(socialRepositoryProvider.future);

    final result = await repo.getWorldName(worldId);

    await Future.delayed(const Duration(milliseconds: 250));

    return result.fold(
          (failure) {
        debugPrint(failure.message);
        return "Unknown World";
      },
          (name) => name,
    );
  } finally {
    _worldFetchLock.release();
  }
}