import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:bang_demo/data/providers/cover_provider.dart';
import 'package:bang_demo/pages/setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/msg_constant.dart';
import '../../core/utils/cover_window.dart';
import '../../data/models/cover.dart';
import '../../data/models/overlay_msg.dart';
import '../edit/edit_page.dart';

/// 主页
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String version = '';

  _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BanGDemo'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(
                      cover: Cover(name: "新增悬浮窗"),
                    ),
                  ),
                ).then((result) {
                  closeCover();
                });
              },
            );
          })
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      "BanGDemo",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  ListTile(
                    title: const Text("设置"),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("v${version ?? ''}"),
            )
          ],
        ),
      ),
      body: const CoversGridView(),
    );
  }
}

/// 悬浮窗列表
class CoversGridView extends StatefulWidget {
  const CoversGridView({super.key});

  @override
  State<CoversGridView> createState() => _CoversGridViewState();
}

class _CoversGridViewState extends State<CoversGridView> {
  final _receivePort = ReceivePort();

  @override
  void initState() {
    super.initState();

    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      portNameHome,
    );
    log("HOME: $res");
    _receivePort.listen((rawMsg) {
      log("HOME get msg: $rawMsg");
      if (rawMsg is Map<String, dynamic>) {
        final msg = OverlayMsg.fromJson(rawMsg);
        switch (msg.type) {
          case MsgType.show:
          case MsgType.setting:
            break;
          case MsgType.close:
            final coverProvider =
                Provider.of<CoverProvider>(context, listen: false);
            coverProvider.clearSelect();
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Consumer<CoverProvider>(
      builder: (context, provider, child) {
        return GridView.count(
          crossAxisCount: isPortrait ? 3 : 6,
          children: [
            for (var cover in provider.list)
              Card(
                color: provider.selected?.id == cover.id
                    ? Theme.of(context).colorScheme.primary
                    : null,
                child: ListTile(
                  title: Text(
                    cover.name,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  subtitle: Text(
                    cover.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onTap: () async {
                    if (provider.selected?.id == cover.id) {
                      provider.clearSelect();
                      provider.closeCover();
                      return;
                    } else {
                      provider.selectCover(cover);
                      provider.showCover();
                    }
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CoverOperationDialog(cover: cover);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 悬浮窗操作对话框
class CoverOperationDialog extends StatelessWidget {
  final Cover cover;

  const CoverOperationDialog({super.key, required this.cover});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("执行操作"),
      content: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: "当前选择的悬浮窗为：",
            ),
            TextSpan(
              text: cover.name,
              style: const TextStyle(color: Colors.blue),
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            "删除",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            final provider = Provider.of<CoverProvider>(context, listen: false);
            provider.clearSelect();
            provider.removeCover(cover.id!);
            provider.closeCover();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("编辑"),
          onPressed: () {
            final provider = Provider.of<CoverProvider>(context, listen: false);
            provider.closeCover();
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(
                  cover: cover,
                ),
              ),
            ).then((result) {
              provider.showCover();
            });
          },
        ),
      ],
    );
  }
}
