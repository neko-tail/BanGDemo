import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:bang_demo/data/providers/setting_provider.dart';
import 'package:bang_demo/pages/home/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_settings/quick_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/msg_constant.dart';
import 'core/utils/cover_window.dart';
import 'data/models/overlay_msg.dart';
import 'data/providers/cover_provider.dart';
import 'data/repositories/cover_repository.dart';
import 'overlays/cover_overlay.dart';

@pragma("vm:entry-point")
Tile onTileClicked(Tile tile) {
  MsgType status = MsgType.close;

  final oldStatus = tile.tileStatus;
  if (oldStatus == TileStatus.active) {
    tile.tileStatus = TileStatus.inactive;

    status = MsgType.close;
  } else {
    tile.tileStatus = TileStatus.active;

    status = MsgType.show;
  }

  Future(() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('selected');
    log("init cover provider, selected id: $id");
    if (id != null) {
      final cover = await CoverRepository().getCover(id);
      SendPort? overlayPort =
          IsolateNameServer.lookupPortByName(portNameOverlay);

      if (overlayPort != null && cover != null) {
        await showOverlay(cover);
        overlayPort.send(OverlayMsg(status, data: cover.toJson()).toJson());
      }
    }
  });

  // Return the updated tile, or null if you don't want to update the tile
  return tile;
}

@pragma("vm:entry-point")
Tile onTileAdded(Tile tile) {
  log("Tile added");
  tile.tileStatus = TileStatus.inactive;

  return tile;
}

@pragma("vm:entry-point")
void onTileRemoved() {
  log("Tile removed");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  QuickSettings.setup(
    onTileClicked: onTileClicked,
    onTileAdded: onTileAdded,
    onTileRemoved: onTileRemoved,
  );

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
