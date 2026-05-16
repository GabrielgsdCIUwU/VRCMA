import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';

void main() {
  group('VrcSemanticColors (ThemeExtension) Tests', () {
    const baseColors = VrcSemanticColors(
      invite: Colors.blue,
      request: Colors.orange,
      response: Colors.green,
      requestResponse: Colors.purple,
      statusOnline: Colors.greenAccent,
      statusJoinMe: Colors.blueAccent,
      statusAskMe: Colors.orangeAccent,
      statusBusy: Colors.redAccent,
      statusOffline: Colors.grey,
      success: Colors.green,
      error: Colors.red,
    );

    test('copyWith should return the exact same values if no arguments are provided', () {
      final copy = baseColors.copyWith() as VrcSemanticColors;

      expect(copy.invite, equals(baseColors.invite));
      expect(copy.error, equals(baseColors.error));
    });

    test('copyWith should return a new object with updated values', () {
      final updatedColors = baseColors.copyWith(
        invite: Colors.cyan,
        error: Colors.deepOrange,
      ) as VrcSemanticColors;

      expect(updatedColors.invite, equals(Colors.cyan));
      expect(updatedColors.error, equals(Colors.deepOrange));
      expect(updatedColors.request, equals(baseColors.request));
    });

    test('lerp should return "this" if the other object is not of the same type', () {
      final result = baseColors.lerp(null, 0.5);
      expect(result, equals(baseColors));
    });

    test('lerp should correctly interpolate between two VrcSemanticColors', () {
      const targetColors = VrcSemanticColors(
        invite: Colors.red,
        request: Colors.orange,
        response: Colors.green,
        requestResponse: Colors.purple,
        statusOnline: Colors.greenAccent,
        statusJoinMe: Colors.blueAccent,
        statusAskMe: Colors.orangeAccent,
        statusBusy: Colors.redAccent,
        statusOffline: Colors.grey,
        success: Colors.green,
        error: Colors.yellow,
      );

      final lerp0 = baseColors.lerp(targetColors, 0.0) as VrcSemanticColors;
      expect(lerp0.invite.toARGB32(), equals(Colors.blue.toARGB32()));

      final lerp1 = baseColors.lerp(targetColors, 1.0) as VrcSemanticColors;
      expect(lerp1.invite.toARGB32(), equals(Colors.red.toARGB32()));

      final lerp50 = baseColors.lerp(targetColors, 0.5) as VrcSemanticColors;
      expect(lerp50.invite, equals(Color.lerp(Colors.blue, Colors.red, 0.5)));
    });
  });

  group('ThemeDataContext Extension Tests', () {
    testWidgets('BuildContext extension should retrieve VrcSemanticColors correctly', (WidgetTester tester) async {
      const testThemeColors = VrcSemanticColors(
        invite: Colors.pink,
        request: Colors.white,
        response: Colors.white,
        requestResponse: Colors.white,
        statusOnline: Colors.white,
        statusJoinMe: Colors.white,
        statusAskMe: Colors.white,
        statusBusy: Colors.white,
        statusOffline: Colors.white,
        success: Colors.white,
        error: Colors.white,
      );

      Color? extractedInviteColor;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [testThemeColors],
          ),
          home: Builder(
            builder: (BuildContext context) {
              extractedInviteColor = context.vrcColors.invite;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(extractedInviteColor, equals(Colors.pink));
    });
  });
}