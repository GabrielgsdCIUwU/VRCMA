import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  group('Database Providers DI Tests', () {
    test('databaseProvider should return an opened Database instance', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final db = await container.read(databaseProvider.future);
      
      expect(db, isA<Database>());
      expect(db.isOpen, true);
    });
    
    test('profileRepositoryProvider should return an implementation of IProfileRepository', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final repo = await container.read(profileRepositoryProvider.future);
      
      expect(repo, isA<IProfileRepository>());
    });
  });
}