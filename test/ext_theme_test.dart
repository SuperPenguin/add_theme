import 'package:ext_theme/ext_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

@immutable
class TestThemeData extends ExtThemeData {
  const TestThemeData({
    required this.testColor,
  });

  final Color testColor;

  @override
  TestThemeData lerpTo(TestThemeData target, double progress) {
    return TestThemeData(
      testColor: Color.lerp(testColor, target.testColor, progress)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! TestThemeData) return false;

    return other.testColor == testColor;
  }

  @override
  int get hashCode => Object.hashAll([testColor]);
}

class TestTheme extends ExtTheme<TestThemeData> {
  const TestTheme({
    Key? key,
    required TestThemeData data,
    required Widget child,
  }) : super(key: key, data: data, child: child);

  static TestThemeData? maybeOf(BuildContext context) =>
      ExtTheme.maybeOf<TestThemeData>(context);

  static TestThemeData of(BuildContext context) =>
      ExtTheme.of<TestThemeData>(context);
}

const testLight = TestThemeData(
  testColor: Color.fromRGBO(255, 0, 0, 1),
);

const testDark = TestThemeData(
  testColor: Color.fromRGBO(0, 0, 255, 1),
);

void main() {
  testWidgets(
    'Insert ExtTheme',
    (WidgetTester tester) async {
      final boxKey = UniqueKey();

      await tester.pumpWidget(
        ExtTheme<TestThemeData>(
          data: testLight,
          child: Builder(
            builder: (context) {
              return ColoredBox(
                key: boxKey,
                color: TestTheme.of(context).testColor,
              );
            },
          ),
        ),
      );

      expect(
        tester.widget<ColoredBox>(find.byKey(boxKey)).color,
        isSameColorAs(testLight.testColor),
      );
    },
  );

  testWidgets(
    'Animated ExtTheme',
    (WidgetTester tester) async {
      TestThemeData current = testLight;
      late StateSetter testSetState;
      final boxKey = UniqueKey();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            testSetState = setState;

            return AnimatedExtTheme<TestThemeData>(
              data: current,
              child: Builder(
                builder: (context) {
                  return ColoredBox(
                    key: boxKey,
                    color: TestTheme.of(context).testColor,
                  );
                },
              ),
            );
          },
        ),
      );

      expect(
        tester.widget<ColoredBox>(find.byKey(boxKey)).color,
        isSameColorAs(testLight.testColor),
      );

      testSetState(() {
        current = testDark;
      });

      await tester.pumpAndSettle(
        kThemeAnimationDuration,
        EnginePhase.sendSemanticsUpdate,
        const Duration(minutes: 1),
      );

      expect(
        tester.widget<ColoredBox>(find.byKey(boxKey)).color,
        isSameColorAs(testDark.testColor),
      );
    },
  );

  testWidgets(
    'ExtThemeApp ThemeMode changes',
    (WidgetTester tester) async {
      var themeMode = ThemeMode.light;
      late StateSetter testSetState;
      final boxKey = UniqueKey();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            testSetState = setState;

            return MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeMode,
              builder: (context, child) {
                return ExtThemeApp<TestThemeData>(
                  theme: testLight,
                  darkTheme: testDark,
                  child: child!,
                );
              },
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final testTheme = TestTheme.of(context);

                    return Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ColoredBox(
                          key: boxKey,
                          color: testTheme.testColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(
        tester.widget<ColoredBox>(find.byKey(boxKey)).color,
        isSameColorAs(testLight.testColor),
      );

      testSetState(() {
        themeMode = ThemeMode.dark;
      });

      await tester.pumpAndSettle(
        kThemeAnimationDuration,
        EnginePhase.sendSemanticsUpdate,
        const Duration(minutes: 1),
      );

      expect(
        tester.widget<ColoredBox>(find.byKey(boxKey)).color,
        isSameColorAs(testDark.testColor),
      );
    },
  );

  testWidgets(
    '.of should throw FlutterError',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ColoredBox(
                    color: TestTheme.of(context).testColor,
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(tester.takeException(), isFlutterError);
    },
  );
}