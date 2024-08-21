import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/msg_constant.dart';
import '../../core/utils/cover_window.dart';
import '../models/cover.dart';
import '../models/overlay_msg.dart';
import '../repositories/cover_repository.dart';

class CoverProvider extends ChangeNotifier {
  final _coverRepository = CoverRepository();
  SharedPreferences? prefs;
  SendPort? _overlayPort;

  final List<Cover> _list = [];

  /// 选中的悬浮窗方案
  Cover? _selected;

  List<Cover> get list => _list;

  Cover? get selected => _selected;

  /// 初始化时根据设置中的 [autoStart] 来决定是否自动开启上一次选中的悬浮窗
  Future<void> init(bool autoStart) async {
    prefs = await SharedPreferences.getInstance();
    if (autoStart) {
      final id = prefs?.getInt('selected');
      log("init cover provider, selected id: $id");
      if (id != null) {
        final cover = await _coverRepository.getCover(id);
        _selected = cover;
        showCover();
      }
    }

    await fetchCovers();
  }

  Future<void> fetchCovers() async {
    final covers = await _coverRepository.listCover();
    _list.clear();
    _list.addAll(covers);
    notifyListeners();
  }

  Future<void> selectCover(Cover cover) async {
    _selected = cover;
    /// 保存选中的悬浮窗，取消选中时不删除
    await prefs?.setInt('selected', _selected!.id!);
    notifyListeners();
  }

  Future<void> clearSelect() async {
    _selected = null;
    notifyListeners();
  }

  _saveImage(Cover cover) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagePath = "${dir.path}/cover/image/${cover.id}.jpg";

    // 未修改图片
    if (cover.image.path == imagePath) {
      return;
    }

    final imageFile = File(imagePath);
    // 如果父目录不存在，需要创建
    if (!await imageFile.parent.exists()) {
      await imageFile.parent.create(recursive: true);
    }

    // // 删除旧图片，如果当前有选择图片，再保存
    // if (imageFile.existsSync()) {
    //   imageFile.deleteSync();
    // }
    if (cover.image.path != null) {
      final tempFile = File(cover.image.path!);
      await tempFile.copy(imagePath);
      await tempFile.delete();
      cover.image.path = imagePath;
    }
  }

  Future<bool> saveCover(Cover cover) async {
    // 图片名称包含 id，新增的数据要先保存，生成 id
    cover.id ??= await _coverRepository.insertCover(cover);

    if (cover.image.enable) {
      await _saveImage(cover);
    }

    final res = await _coverRepository.updateCover(cover) > 0;
    await fetchCovers();
    return res;
  }

  Future<int> removeCover(int id) async {
    final cover = await _coverRepository.getCover(id);
    if (cover != null && cover.image.enable && cover.image.path != null) {
      File(cover.image.path!).deleteSync();
    }

    final res = await _coverRepository.deleteCover(id);
    await fetchCovers();
    return res;
  }

  showCover() async {
    _overlayPort ??= IsolateNameServer.lookupPortByName(portNameOverlay);

    if (_overlayPort == null || selected == null) {
      return;
    }

    await showOverlay(selected!);
    _overlayPort
        ?.send(OverlayMsg(MsgType.show, data: selected!.toJson()).toJson());
  }

  closeCover() {
    _overlayPort ??= IsolateNameServer.lookupPortByName(portNameOverlay);

    if (_overlayPort == null) {
      return;
    }

    _overlayPort?.send(OverlayMsg(MsgType.close).toJson());
  }
}
