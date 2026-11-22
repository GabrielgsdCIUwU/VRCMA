import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/presentation/state/app_settings_provider.dart';
part 'navigation_provider.g.dart';

@riverpod
class NavigationStack extends _$NavigationStack {
  @override
  AppRoute build() => AppRoute.dashboard;
  
  void setRoute(AppRoute route) => state = route;
}

