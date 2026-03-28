import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'navigation_provider.g.dart';

@riverpod
class NavigationStack extends _$NavigationStack {
  @override
  int build() => 1;
  
  void setIndex(int index) => state = index;
}

