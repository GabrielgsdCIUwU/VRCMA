import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pool/pool.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';

part 'world_cache_provider.g.dart';

final _worldFetchLock = Pool(3, timeout: const Duration(seconds: 15));

@riverpod
Future<String> worldName(Ref ref, String worldId) async {
  if (worldId.isEmpty || !worldId.startsWith('wrld_')) return "Unknown World";

  final keepAliveLink = ref.keepAlive();
  Timer? timer;
  
  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 5), () => keepAliveLink.close());
  });
  ref.onResume(() {
    timer?.cancel();
  });

  final repo = await ref.watch(socialRepositoryProvider.future);
  return await _worldFetchLock.withResource(() async {

    final result = await repo.getWorldName(worldId);

    await Future.delayed(const Duration(milliseconds: 250));

    return result.fold(
          (failure) {
        debugPrint(failure.message);
        return "Unknown World";
      },
          (name) => name,
    );
  });
}