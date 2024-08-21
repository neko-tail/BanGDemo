import 'package:bang_demo/data/providers/setting_provider.dart';
import 'package:bang_demo/pages/home/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/providers/cover_provider.dart';
import 'overlays/cover_overlay.dart';

void main() {
  runApp(const MyApp());
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CoverOverlay(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _coverProvider = CoverProvider();
  final _settingProvider = SettingProvider();
  late ThemeMode themeMode;

  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.cyan,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      primary: Colors.cyan,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.cyan,
    ),
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.cyan,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      primary: Colors.cyan,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.cyan,
    ),
  );

  _initProvider() async {
    await _settingProvider.init();
    await _coverProvider.init(_settingProvider.setting!.autoStart);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initProvider();
    themeMode = ThemeMode.system;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // 模拟器中，程序退出后悬浮窗不会自动关闭，但在真机上会，先注释掉
      // _coverProvider.closeCover();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _coverProvider),
        ChangeNotifierProvider.value(value: _settingProvider),
      ],
      child: MaterialApp(
        title: 'BanGDemo',
        theme: theme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: const MainPage(),
      ),
    );
  }
}
