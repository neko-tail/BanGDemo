import 'dart:isolate';
import 'dart:ui';

import 'package:bang_demo/data/models/cover.dart';
import 'package:flutter/material.dart';

import '../../core/constants/msg_constant.dart';
import '../../core/utils/cover_window.dart';
import '../models/overlay_msg.dart';

class CoverFormViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey;
  final Cover cover;

  /// ExpansionPanelList 中的三个 panel 是否打开
  final List<bool> _isOpen;

  SendPort? overlayPort;

  CoverFormViewModel(this.cover, this.formKey)
      : _isOpen = [true, cover.text.enable, cover.image.enable];

  /// 基础信息 panel
  bool get basicIsOpen => _isOpen[0];

  set basicIsOpen(bool value) {
    _isOpen[0] = value;
    notifyListeners();
  }

  /// 文本 panel
  bool get textIsOpen => _isOpen[1];

  setTextIsOpen(bool value) {
    _isOpen[1] = value;
    notifyListeners();
  }

  /// 图片 panel
  bool get imageIsOpen => _isOpen[2];

  set imageIsOpen(bool value) {
    _isOpen[2] = value;
    notifyListeners();
  }

  /// 设置指定 panel 是否打开，提供给 ExpansionPanelList 的 expansionCallback 使用
  void setOpen(int index, bool value) {
    _isOpen[index] = value;
    notifyListeners();
  }

  /// 验证表单
  bool validate() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    formKey.currentState!.save();

    return true;
  }

  /// 显示悬浮窗
  void showCover() async {
    final ok = validate();
    if (!ok) {
      return;
    }

    await showOverlay(cover);

    overlayPort ??= IsolateNameServer.lookupPortByName(portNameOverlay);
    overlayPort?.send(OverlayMsg(MsgType.show, data: cover.toJson()).toJson());
  }
}
