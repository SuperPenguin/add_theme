import 'package:flutter/material.dart';

/// Lerp a `double` from a to b.
/// Both value has to be finite.
double lerpDouble(double a, double b, double progress) {
  assert(a.isFinite);
  assert(b.isFinite);

  return a * (1.0 - progress) + b * progress;
}

/// Lerp a `String` from a to b.
/// This both lerp the content and length of string.
String lerpString(String a, String b, double progress) {
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

/// Lerp a `Color` from a to b.
/// this is only a wrapper for `Color.lerp` without the `Color?`.
Color lerpColor(Color a, Color b, double progress) =>
    Color.lerp(a, b, progress)!;

/// Lerp a `Size` from a to b.
/// Both value width and height has to be finite.
Size lerpSize(Size a, Size b, double progress) {
  assert(a.isFinite);
  assert(b.isFinite);

  return Size(
    lerpDouble(a.width, b.width, progress),
    lerpDouble(a.height, b.height, progress),
  );
}
