import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pool/pool.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';

part 'world_cache_provider.g.dart';

final _worldFetchLock = Pool(3, timeout: const Duration(seconds: 15));

@Riverpod(keepAlive: true)
Future<String> worldName(Ref ref, String worldId) async {
  if (worldId.isEmpty || !worldId.startsWith('wrld_')) return "Unknown World";

  return await _worldFetchLock.withResource(() async {
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
  });
}