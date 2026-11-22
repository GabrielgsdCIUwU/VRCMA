import 'package:mockito/annotations.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrchat_dart/src/api/src/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:vrcma/domain/repositories/i_auth_repository.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_local_calendar_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_message_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/repositories/i_app_log_repository.dart';
import 'package:vrcma/domain/repositories/i_remote_calendar_repository.dart';
import 'package:vrcma/domain/repositories/i_social_repository.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

@GenerateMocks([
  VrchatDart,
  AuthApi,
  AuthenticationApi,
  CookieJar,
  Dio,
  IAuthRepository,
  IMessageRepository,
  ISocialRepository,
  IAutomationRepository,
  ILocalSocialRepository,
  IProfileRepository,
  IAppLogRepository,
  ILocalCalendarRepository,
  IRemoteCalendarRepository,
  ProcessInvitationUseCase,
  MessageSlotManager
])
void main() {}