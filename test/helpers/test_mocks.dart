import 'package:mockito/annotations.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:dio/dio.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/repositories/i_log_repository.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

@GenerateMocks([
  VrchatDart,
  AuthenticationApi,
  CookieJar,
  Dio,
  IAutomationRepository,
  ILocalSocialRepository,
  IProfileRepository,
  ILogRepository,
  ProcessInvitationUseCase
])
void main() {}