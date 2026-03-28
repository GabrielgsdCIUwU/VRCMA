import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

part 'automation_provider.g.dart';

@riverpod
class AutomationState extends _$AutomationState {
  @override
  void build() {
    _listenToInvitations();
  }
  
  void _listenToInvitations() async {
    ref.read(authRepositoryProvider);
  }
}