import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../../data/models/cover.dart';

/// 显示悬浮窗
Future<bool> showOverlay(Cover cover) async {
  if (await FlutterOverlayWindow.isActive()) {
    await FlutterOverlayWindow.closeOverlay();
  }

  if (!await FlutterOverlayWindow.isPermissionGranted()) {
    final bool res = await FlutterOverlayWindow.requestPermission() ?? false;
    if (res == false) {
      return false;
    }
  }

  await FlutterOverlayWindow.showOverlay(
    enableDrag: true,
    flag: OverlayFlag.defaultFlag,
    alignment: cover.constraint.overlayAlignment ?? OverlayAlignment.topCenter,
    visibility: NotificationVisibility.visibilityPublic,
    positionGravity: PositionGravity.none,
    width: cover.constraint.width.toInt(),
    height: cover.constraint.height.toInt(),
    startPosition:
        OverlayPosition(cover.constraint.xOffset, cover.constraint.yOffset),
  );

  return true;
}

/// 关闭悬浮窗
Future<bool> closeCover() async {
  return await FlutterOverlayWindow.closeOverlay() ?? false;
}
