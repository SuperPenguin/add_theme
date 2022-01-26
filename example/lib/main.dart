import 'package:add_theme/add_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      builder: (context, child) => AddThemeApp<ExtendedThemeData>(
        theme: const ExtendedThemeData(
          appBarText: 'Light',
          customWidgetTheme: CustomWidgetThemeData(
            textColor: Colors.orange,
            borderColor: Colors.red,
          ),
        ),
        darkTheme: const ExtendedThemeData(
          appBarText: 'Dark',
          customWidgetTheme: CustomWidgetThemeData(
            textColor: Colors.cyan,
            borderColor: Colors.blue,
          ),
        ),
        child: child!,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final extendedTheme = ExtendedTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(extendedTheme.appBarText),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          const Center(
            child: CustomWidget(
              text: 'Custom Widget 1',
            ),
          ),
          const SizedBox(height: 8.0),
          Center(
            child: CustomWidgetTheme(
              data: CustomWidgetTheme.of(context).copyWith(
                textColor: Colors.green,
              ),
              child: const CustomWidget(
                text: 'Custom Widget 2',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExtendedTheme extends AddTheme {
  const ExtendedTheme({
    Key? key,
    required ExtendedThemeData data,
    required Widget child,
  }) : super(key: key, data: data, child: child);

  static ExtendedThemeData of(BuildContext context) {
    return AddTheme.of<ExtendedThemeData>(context);
  }

  static ExtendedThemeData? maybeOf(BuildContext context) {
    return AddTheme.maybeOf<ExtendedThemeData>(context);
  }
}

class ExtendedThemeData extends AddThemeData {
  const ExtendedThemeData({
    required this.appBarText,
    required this.customWidgetTheme,
  });

  final String appBarText;
  final CustomWidgetThemeData customWidgetTheme;

  @override
  ExtendedThemeData lerpTo(ExtendedThemeData target, double progress) {
    return ExtendedThemeData(
      appBarText: lerpString(appBarText, target.appBarText, progress),
      customWidgetTheme: customWidgetTheme.lerpTo(
        target.customWidgetTheme,
        progress,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;

    return other is ExtendedThemeData &&
        appBarText == other.appBarText &&
        customWidgetTheme == other.customWidgetTheme;
  }

  @override
  int get hashCode {
    return Object.hashAll([appBarText, customWidgetTheme]);
  }
}

class CustomWidget extends StatelessWidget {
  const CustomWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final widgetTheme = CustomWidgetTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: widgetTheme.borderColor,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            color: widgetTheme.textColor,
          ),
        ),
      ),
    );
  }
}

class CustomWidgetTheme extends AddTheme<CustomWidgetThemeData> {
  const CustomWidgetTheme({
    Key? key,
    required CustomWidgetThemeData data,
    required Widget child,
  }) : super(key: key, data: data, child: child);

  static CustomWidgetThemeData of(BuildContext context) {
    // Return nearest CustomWidgetTheme data if any
    final inherited = AddTheme.maybeOf<CustomWidgetThemeData>(context);
    if (inherited != null) return inherited;

    // Return data from ExtendedTheme
    return ExtendedTheme.of(context).customWidgetTheme;
  }
}

class CustomWidgetThemeData extends AddThemeData {
  const CustomWidgetThemeData({
    required this.textColor,
    required this.borderColor,
  });

  final Color textColor;
  final Color borderColor;

  CustomWidgetThemeData copyWith({
    Color? textColor,
    Color? borderColor,
  }) {
    return CustomWidgetThemeData(
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  CustomWidgetThemeData lerpTo(CustomWidgetThemeData target, double progress) {
    return CustomWidgetThemeData(
      textColor: lerpColor(textColor, target.textColor, progress),
      borderColor: lerpColor(borderColor, target.borderColor, progress),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;

    return other is CustomWidgetThemeData &&
        textColor == other.textColor &&
        borderColor == other.borderColor;
  }

  @override
  int get hashCode {
    return Object.hashAll([textColor, borderColor]);
  }
}
