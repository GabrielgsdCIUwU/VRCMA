import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/data/repositories/automation_repository_imp.dart';
import 'package:vrcma/data/repositories/social_repository_imp.dart';
import 'package:vrcma/data/transformers/vrc_event_transformer.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_social_repository.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

part 'network_repository_provider.g.dart';

@riverpod
List<VrcEventTransformer> vrcTransformers(Ref ref) {
  return [
    FriendRequestTransformer(),
    InviteReceivedTransformer(),
    RequestReceivedTransformer(),
  ];
}

@riverpod
Future<IAutomationRepository> automationRepository(Ref ref) async {
  final api = await ref.watch(vrcApiProvider.future);
  final transformers = ref.watch(vrcTransformersProvider);
  return AutomationRepositoryImp(api, transformers);
}

@riverpod
Future<ISocialRepository> socialRepository(Ref ref) async {
  final api = await ref.watch(vrcApiProvider.future);
  return SocialRepositoryImp(api);
}