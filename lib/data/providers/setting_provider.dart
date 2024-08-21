import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/constants/msg_constant.dart';
import '../models/overlay_msg.dart';
import '../models/setting.dart';
import '../repositories/setting_repository.dart';

class SettingProvider extends ChangeNotifier {
  final _repository = SettingRepository();

  SendPort? _overlayPort;
  Setting? setting;

  Future<void> init() async {
    await fetchSetting();
  }

  Future<void> fetchSetting() async {
    setting = await _repository.getSetting();

    _overlayPort ??=
        IsolateNameServer.lookupPortByName(portNameOverlay);

    if (_overlayPort == null || setting == null) {
      return;
    }

    _overlayPort?.send(OverlayMsg(MsgType.setting,
        data: setting!.toJson())
        .toJson());

    notifyListeners();
  }

  Future<bool> updateSetting(Setting setting) async {
    final res = await _repository.updateSetting(setting);

    fetchSetting();
    return res > 0;
  }

  Future<bool> resetSetting() async {
    final res = await _repository.resetDefault();

    fetchSetting();
    return res > 0;
  }
}