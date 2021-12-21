import 'package:flutter/material.dart';

class ExtThemeApp<T extends ExtThemeData> extends StatelessWidget {
  const ExtThemeApp({
    Key? key,
    required this.theme,
    this.darkTheme,
    required this.child,
  }) : super(key: key);

  final T theme;
  final T? darkTheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final targetTheme = isLightTheme ? theme : darkTheme ?? theme;

    return AnimatedExtTheme<T>(
      data: targetTheme,
      child: child,
    );
  }
}

class AnimatedExtTheme<T extends ExtThemeData>
    extends ImplicitlyAnimatedWidget {
  const AnimatedExtTheme({
    Key? key,
    required this.data,
    Curve curve = Curves.linear,
    Duration duration = kThemeAnimationDuration,
    VoidCallback? onEnd,
    required this.child,
  }) : super(
          key: key,
          curve: curve,
          duration: duration,
          onEnd: onEnd,
        );

  final T data;
  final Widget child;

  @override
  _AnimatedExtThemeState createState() => _AnimatedExtThemeState<T>();
}

class _AnimatedExtThemeState<T extends ExtThemeData>
    extends AnimatedWidgetBaseState<AnimatedExtTheme> {
  ExtThemeDataTween<T>? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
      _data,
      widget.data,
      (dynamic value) => ExtThemeDataTween<T>(begin: value as T),
    )! as ExtThemeDataTween<T>;
  }

  @override
  Widget build(BuildContext context) {
    return ExtTheme<T>(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }
}

class ExtTheme<T extends ExtThemeData> extends StatelessWidget {
  const ExtTheme({
    Key? key,
    required this.data,
    required this.child,
  }) : super(key: key);

  final T data;
  final Widget child;

  static T of<T extends ExtThemeData>(BuildContext context) {
    final data = maybeOf<T>(context);
    if (data != null) {
      return data;
    }

    throw FlutterError.fromParts([
      ErrorSummary(
        'Can\'t find a ExtTheme of $T, the context used doesn\'t have any ancestor $T',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  static T? maybeOf<T extends ExtThemeData>(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedExtTheme<T>>();
    return inherited?.theme.data;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedExtTheme<T>(
      theme: this,
      child: child,
    );
  }
}

class _InheritedExtTheme<T extends ExtThemeData> extends InheritedWidget {
  const _InheritedExtTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final ExtTheme<T> theme;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    if (oldWidget is! _InheritedExtTheme<T>) return true;

    return oldWidget.theme.data != theme.data;
  }
}

@immutable
abstract class ExtThemeData {
  const ExtThemeData();

  @protected
  ExtThemeData lerpTo(covariant ExtThemeData target, double progress);
}

class ExtThemeDataTween<T extends ExtThemeData> extends Tween<T> {
  ExtThemeDataTween({
    T? begin,
    T? end,
  }) : super(
          begin: begin,
          end: end,
        );

  @override
  T lerp(double t) => begin!.lerpTo(end!, t) as T;
}

abstract class ExtThemeUtils {
  static double doubleLerp(double a, double b, double progress) {
    assert(a.isFinite);
    assert(b.isFinite);

    return a * (1.0 - progress) + b * progress;
  }

  static String stringLerp(String a, String b, double progress) {
    final int len1 = ((b.length - a.length) * progress + a.length).truncate();
    final int len2 = (b.length * progress).truncate();
    final String str2 = b.substring(0, len2);
    final String str1 = a.length > len2
        ? len1 > 0 && len1 < a.length
            ? a.substring(len2, len1)
            : a.substring(len2)
        : '';

    return str2 + str1;
  }
}
