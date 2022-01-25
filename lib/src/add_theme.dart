import 'package:flutter/material.dart';

class AddThemeApp<T extends AddThemeData> extends StatelessWidget {
  const AddThemeApp({
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

    return AnimatedAddTheme<T>(
      data: targetTheme,
      child: child,
    );
  }
}

class AnimatedAddTheme<T extends AddThemeData>
    extends ImplicitlyAnimatedWidget {
  const AnimatedAddTheme({
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
  _AnimatedAddThemeState createState() => _AnimatedAddThemeState<T>();
}

class _AnimatedAddThemeState<T extends AddThemeData>
    extends AnimatedWidgetBaseState<AnimatedAddTheme> {
  AddThemeDataTween<T>? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
      _data,
      widget.data,
      (dynamic value) => AddThemeDataTween<T>(begin: value as T),
    )! as AddThemeDataTween<T>;
  }

  @override
  Widget build(BuildContext context) {
    return AddTheme<T>(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }
}

class AddTheme<T extends AddThemeData> extends InheritedWidget {
  const AddTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final T data;

  static T of<T extends AddThemeData>(BuildContext context) {
    final data = maybeOf<T>(context);
    if (data != null) {
      return data;
    }

    throw FlutterError.fromParts([
      ErrorSummary(
        'Can\'t find a AddTheme of $T, the context used doesn\'t have any ancestor $T',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  static T? maybeOf<T extends AddThemeData>(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<AddTheme<T>>();
    return inherited?.data;
  }

  @override
  bool updateShouldNotify(AddTheme<T> oldWidget) {
    return data != oldWidget.data;
  }
}

@immutable
abstract class AddThemeData {
  const AddThemeData();

  @protected
  AddThemeData lerpTo(covariant AddThemeData target, double progress);
}

class AddThemeDataTween<T extends AddThemeData> extends Tween<T> {
  AddThemeDataTween({
    T? begin,
    T? end,
  }) : super(
          begin: begin,
          end: end,
        );

  @override
  T lerp(double t) => begin!.lerpTo(end!, t) as T;
}
