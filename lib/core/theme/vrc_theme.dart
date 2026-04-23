import 'package:flutter/material.dart';

class VrcSemanticColors extends ThemeExtension<VrcSemanticColors> {
  final Color invite;
  final Color request;
  final Color response;
  final Color requestResponse;
  
  final Color statusOnline;
  final Color statusJoinMe;
  final Color statusAskMe;
  final Color statusBusy;
  final Color statusOffline;
  
  final Color success;
  final Color error;
  
  const VrcSemanticColors({
    required this.invite,
    required this.request,
    required this.response,
    required this.requestResponse,
    required this.statusOnline,
    required this.statusJoinMe,
    required this.statusAskMe,
    required this.statusBusy,
    required this.statusOffline,
    required this.success,
    required this.error,
  });
  
  @override
  ThemeExtension<VrcSemanticColors> copyWith({
    Color? invite, Color? request, Color? response, Color? requestResponse,
    Color? statusOnline, Color? statusJoinMe, Color? statusAskMe, Color? statusBusy, Color? statusOffline,
    Color? success, Color? error,
  }) {
    return VrcSemanticColors(
      invite: invite ?? this.invite,
      request: request ?? this.request,
      response: response ?? this.response,
      requestResponse: requestResponse ?? this.requestResponse,
      statusOnline: statusOnline ?? this.statusOnline,
      statusJoinMe: statusJoinMe ?? this.statusJoinMe,
      statusAskMe: statusAskMe ?? this.statusAskMe,
      statusBusy: statusBusy ?? this.statusBusy,
      statusOffline: statusOffline ?? this.statusOffline,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
  
  @override
  ThemeExtension<VrcSemanticColors> lerp(covariant ThemeExtension<VrcSemanticColors>? other, double t) {
    if (other is! VrcSemanticColors) return this;
    return VrcSemanticColors(
      invite: Color.lerp(invite, other.invite, t)!,
      request: Color.lerp(request, other.request, t)!,
      response: Color.lerp(response, other.response, t)!,
      requestResponse: Color.lerp(requestResponse, other.requestResponse, t)!,
      statusOnline: Color.lerp(statusOnline, other.statusOnline, t)!,
      statusJoinMe: Color.lerp(statusJoinMe, other.statusJoinMe, t)!,
      statusAskMe: Color.lerp(statusAskMe, other.statusAskMe, t)!,
      statusBusy: Color.lerp(statusBusy, other.statusBusy, t)!,
      statusOffline: Color.lerp(statusOffline, other.statusOffline, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension ThemeDataContext on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  VrcSemanticColors get vrcColors => Theme.of(this).extension<VrcSemanticColors>()!;
}