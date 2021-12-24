# Ext Theme

Ext Theme is a copy of how Theme works but you could extends it to define your extended Theme.

## Installing

Add by git

```yaml
dependencies:
  ext_theme:
    git:
      url: https://github.com/SuperPenguin/ext_theme.git
```

## Example

Define your own ThemeData extending `ExtThemeData`, you have to implement `lerpTo`, `operator ==`, and `hashCode` to make it work properly.

```dart
@immutable
class MyThemeData extends ExtThemeData {
  const MyThemeData({
    required this.colorA,
    required this.colorB,
    required this.doubleA,
    required this.doubleB,
  });

  final Color colorA;
  final Color colorB;
  final double doubleA;
  final double doubleB;

  @override
  MyThemeData lerpTo(MyThemeData target, double progress) {
    return MyThemeData(
      colorA: lerpColor(colorA, target.colorA, progress)!,
      colorB: lerpColor(colorB, target.colorB, progress)!,
      doubleA: lerpDouble(doubleA, target.doubleA, progress),
      doubleB: lerpDouble(doubleB, target.doubleB, progress),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! MyThemeData) return false;

    return other.colorA == colorA &&
        other.colorB == colorB &&
        other.doubleA == doubleA &&
        other.doubleB == doubleB;
  }

  @override
  int get hashCode => Object.hashAll([
        colorA,
        colorB,
        doubleA,
        doubleB,
      ]);
}
```

Add `ExtThemeApp`, or `ExtTheme`, or `AnimatedExtTheme` to your MaterialApp builder

```dart
return MaterialApp(
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
  themeMode: themeMode,
  builder: (context, child) {
    return ExtThemeApp<MyThemeData>(
      theme: myLightTheme,
      darkTheme: myDarkTheme,
      child: child!,
    );
  },
```

Use it like how you get Theme on your Widget

```dart
class YourWidget extends StatelessWidget {
  const YourWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myTheme = ExtTheme.of<MyThemeData>(context);

    ....
  }
}
```

optionally you could also extends the ExtTheme and add the `of` method for convenience

```dart
class MyTheme extends ExtTheme<MyThemeData> {
  const MyTheme({
    Key? key,
    required MyThemeData data,
    required Widget child,
  }) : super(key: key, data: data, child: child);

  static MyThemeData? maybeOf(BuildContext context) =>
      ExtTheme.maybeOf<MyThemeData>(context);

  static MyThemeData of(BuildContext context) =>
      ExtTheme.of<MyThemeData>(context);
}

class YourWidget extends StatelessWidget {
  const YourWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myTheme = MyTheme.of(context);

    ....
  }
}
```