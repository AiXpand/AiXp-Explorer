import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:e2_explorer/dart_e2/ec_signature_verify/aixp_wallet.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/themes/app_theme.dart';
import 'package:e2_explorer/src/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

AixpWallet? kAIXpWallet;

/// Todo: implemented for test. Remove once test completed.
Future<void> clearServersAndDefaultServer() async {
  const String mqttServersKey = 'mqtt_servers';
  const String selectedServerNameKey = 'selected_server_name';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(mqttServersKey);
  await prefs.remove(selectedServerNameKey);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Check which theme to use and initialize the colors according to theme.
  await ThemeUtils.initialize();

  // await clearServersAndDefaultServer();
  runApp(const ProviderScope(child: MyApp()));

  doWhenWindowReady(() {
    // const initialSize = Size(1400, 800);

    // appWindow.minSize = initialSize;
    final initialSize = Size(1400, 800);
    // final minSize = Size(600, 450);
    final maxSize = Size(2800, 1400);
    appWindow.maxSize = maxSize;
    // appWindow.minSize = minSize;
    appWindow.size = initialSize;
    // appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'AiExpand';
    appWindow.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      kAIXpWallet = AixpWallet(isDebug: true);
    });
    ThemeUtils.themeValueNotifier.addListener(_listenToThemeChanges);
    super.initState();
  }

  void _listenToThemeChanges() {
    ThemeUtils.loadThemeColors();
    setState(() {});
    rebuildAllChildren(context);
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el
        ..markNeedsBuild()
        ..visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  void dispose() {
    ThemeUtils.themeValueNotifier.removeListener(_listenToThemeChanges);
    super.dispose();
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    AppColors.initialize();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MQTT Connection Demo',
      theme: appTheme,
      routerConfig: AppRoutes.routes,
      scaffoldMessengerKey: AppRoutes.scaffoldMessengerKey,
    );
  }
}
