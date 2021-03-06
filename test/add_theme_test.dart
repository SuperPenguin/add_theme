import 'package:add_theme/add_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

@immutable
class TestThemeData extends AddThemeData {
  const TestThemeData({
    required this.testColor,
    required this.testChildTheme,
  });

  final Color testColor;
  final TestChildThemeData testChildTheme;

  @override
  TestThemeData lerpTo(TestThemeData target, double progress) {
    return TestThemeData(
      testColor: lerpColor(testColor, target.testColor, progress),
      testChildTheme: testChildTheme.lerpTo(target.testChildTheme, progress),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! TestThemeData) return false;

    return other.testColor == testColor &&
        other.testChildTheme == testChildTheme;
  }

  @override
  int get hashCode => Object.hashAll([testColor, testChildTheme]);
}

class TestChildThemeData extends AddThemeData {
  const TestChildThemeData({
    required this.testChildColor,
  });

  final Color testChildColor;

  @override
  TestChildThemeData lerpTo(TestChildThemeData target, double progress) {
    return TestChildThemeData(
      testChildColor: lerpColor(
        testChildColor,
        target.testChildColor,
        progress,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! TestChildThemeData) return false;

    return other.testChildColor == testChildColor;
  }

  @override
  int get hashCode => Object.hashAll([testChildColor]);
}

class TestTheme extends AddTheme<TestThemeData> {
  const TestTheme({
    Key? key,
    required TestThemeData data,
    required Widget child,
  }) : super(key: key, data: data, child: child);

  static TestThemeData? maybeOf(BuildContext context) =>
      AddTheme.maybeOf<TestThemeData>(context);

  static TestThemeData of(BuildContext context) =>
      AddTheme.of<TestThemeData>(context);
}

const testLight = TestThemeData(
  testColor: Color.fromRGBO(255, 0, 0, 1),
  testChildTheme: TestChildThemeData(
    testChildColor: Color.fromRGBO(255, 255, 0, 1),
  ),
);

const testDark = TestThemeData(
  testColor: Color.fromRGBO(0, 0, 255, 1),
  testChildTheme: TestChildThemeData(
    testChildColor: Color.fromRGBO(0, 255, 255, 1),
  ),
);

class _SizeMatcher extends Matcher {
  const _SizeMatcher({
    required this.targetSize,
  });

  final Size targetSize;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! Size) return false;

    return item == targetSize ||
        (item.width == targetSize.width && item.height == targetSize.height);
  }

  @override
  Description describe(Description description) =>
      description.add('matches Size $targetSize');
}

void main() {
  // Lerp
  test('Lerp Double', () async {
    double a = 0.0;
    double b = 100.0;

    double start = lerpDouble(a, b, 0.0);
    double end = lerpDouble(a, b, 1.0);

    expect(start, a);
    expect(end, b);
  });

  test('Lerp String', () async {
    String a = 'Hello, World!';
    String b = 'Flutter';

    String start = lerpString(a, b, 0.0);
    String end = lerpString(a, b, 1.0);

    expect(start, a);
    expect(end, b);
  });

  test('Lerp Color', () async {
    Color a = Colors.red;
    Color b = Colors.blue;

    Color start = lerpColor(a, b, 0.0);
    Color end = lerpColor(a, b, 1.0);

    expect(start, isSameColorAs(a));
    expect(end, isSameColorAs(b));
  });

  test('Lerp Size', () async {
    Size a = const Size(100.0, 100.0);
    Size b = const Size(1000.0, 1000.0);

    Size start = lerpSize(a, b, 0.0);
    Size end = lerpSize(a, b, 1.0);

    expect(start, _SizeMatcher(targetSize: a));
    expect(end, _SizeMatcher(targetSize: b));
  });

  // Widgets
  testWidgets('Insert AddTheme', (WidgetTester tester) async {
    final boxKey = UniqueKey();

    await tester.pumpWidget(
      AddTheme<TestThemeData>(
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
  });

  testWidgets('Animated AddTheme', (WidgetTester tester) async {
    TestThemeData current = testLight;
    late StateSetter testSetState;
    final boxKey = UniqueKey();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          testSetState = setState;

          return AnimatedAddTheme<TestThemeData>(
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
  });

  testWidgets('AddThemeApp ThemeMode changes', (WidgetTester tester) async {
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
              return AddThemeApp<TestThemeData>(
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
  });

  testWidgets(
    'Nested ThemeData',
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
                return AddThemeApp<TestThemeData>(
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
                          color: testTheme.testChildTheme.testChildColor,
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

      expect(tester.takeException(), isNull);

      expect(
        tester.widget<ColoredBox>(find.byKey(boxKey)).color,
        isSameColorAs(testLight.testChildTheme.testChildColor),
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
        isSameColorAs(testDark.testChildTheme.testChildColor),
      );
    },
  );

  testWidgets('.of should throw FlutterError', (WidgetTester tester) async {
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
  });
}
