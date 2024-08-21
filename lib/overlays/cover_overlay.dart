import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bang_demo/data/models/cover.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../core/constants/msg_constant.dart';
import '../core/utils/cover_window.dart';
import '../data/models/overlay_msg.dart';
import '../data/models/setting.dart';

/// 悬浮窗
class CoverOverlay extends StatefulWidget {
  const CoverOverlay({super.key});

  @override
  State<CoverOverlay> createState() => _CoverOverlayState();
}

class _CoverOverlayState extends State<CoverOverlay> {
  final _receivePort = ReceivePort();
  SendPort? homePort;

  static const _customTapInterval = Duration(milliseconds: 300);
  Timer? _customTapTimer;

  late Cover rawCover;
  late Cover cover;

  Setting? setting;

  void _processGestureEvent(GestureEvent? event) {
    if (event == null) {
      return;
    }
    switch (event) {
      case GestureEvent.none:
        break;
      case GestureEvent.reset:
        // 回到初始位置
        FlutterOverlayWindow.moveOverlay(OverlayPosition(
            cover.constraint.xOffset, cover.constraint.yOffset));
        break;
      case GestureEvent.close:
        // 关闭悬浮窗
        homePort ??= IsolateNameServer.lookupPortByName(portNameHome);
        homePort?.send(OverlayMsg(MsgType.close).toJson());
        closeCover();
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    rawCover = Cover(
      id: -1,
      name: "default cover",
      description: "default description",
    );
    cover = rawCover.clone();

    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      portNameOverlay,
    );
    log("OVERLAY: $res");
    _receivePort.listen((rawMsg) async {
      log("OVERLAY get msg: $rawMsg");
      if (rawMsg is Map<String, dynamic>) {
        final msg = OverlayMsg.fromJson(rawMsg);
        switch (msg.type) {
          case MsgType.show:
            final newCover = Cover.fromJson(msg.data as Map<String, dynamic>);
            setState(() {
              rawCover = newCover;
              cover = rawCover.clone();
            });
            break;
          case MsgType.close:
            closeCover();
            break;
          case MsgType.setting:
            final newSetting =
                Setting.fromJson(msg.data as Map<String, dynamic>);
            setState(() {
              setting = newSetting;
            });
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    log("device pixel ratio: $ratio");
    // 悬浮窗内比例不同，根据设备实际比例进行缩放
    // build 方法会被多次调用，所以克隆一份来缩放
    cover = rawCover.clone()
      ..scale(ratio)
      ..image.constraint.scale(ratio)
      ..text.constraint.scale(ratio);

    return RawGestureDetector(
      gestures: {
        SerialTapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<SerialTapGestureRecognizer>(
                SerialTapGestureRecognizer.new,
                (SerialTapGestureRecognizer instance) {
          instance.onSerialTapUp = (SerialTapUpDetails details) {
            if (details.count > 3) {
              log("more than triple tap overlay");
              return;
            }

            if (_customTapTimer != null && _customTapTimer!.isActive) {
              _customTapTimer!.cancel();
              _customTapTimer = null;
            }
            switch (details.count) {
              case 1:
                _customTapTimer = Timer(_customTapInterval, () {
                  log("single tap overlay");
                  _processGestureEvent(setting?.gesture.tap);
                });
                break;
              case 2:
                _customTapTimer = Timer(_customTapInterval, () {
                  log("double tap overlay");
                  _processGestureEvent(setting?.gesture.doubleTap);
                });
                break;
              case 3:
                _customTapTimer = Timer(_customTapInterval, () {
                  log("triple tap overlay");
                  _processGestureEvent(setting?.gesture.tripleTap);
                });
                break;
            }
          };
        })
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () async {
          // 长按关闭悬浮窗，会导致重新开启后，悬浮窗的 onTap 和 onLongPress 无效
          log("long press overlay");
          _processGestureEvent(setting?.gesture.longPress);
        },
        child: Container(
          width: cover.constraint.width,
          height: cover.constraint.height,
          decoration: BoxDecoration(
            color: cover.color,
            borderRadius: BorderRadius.circular(cover.borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cover.borderRadius),
            child: Stack(
              children: [
                if (cover.image.enable && cover.image.path != null)
                  ConstraintBox(
                    parentConstraint: cover.constraint,
                    constraint: cover.image.constraint,
                    child: Opacity(
                      opacity: cover.image.opacity,
                      child: Image.file(
                        File(cover.image.path!),
                        width: cover.image.constraint.width,
                        height: cover.image.constraint.height,
                        fit: cover.image.fit,
                      ),
                    ),
                  ),
                if (cover.text.enable)
                  ConstraintBox(
                    parentConstraint: cover.constraint,
                    constraint: cover.text.constraint,
                    child: Text(
                      cover.text.content,
                      textAlign: cover.text.align,
                      softWrap: true,
                      style: TextStyle(
                        overflow: TextOverflow.clip,
                        color: cover.text.color,
                        fontSize: cover.text.size.toDouble(),
                        fontWeight: cover.text.weight,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 对 [child] 应用 [constraint] 约束
class ConstraintBox extends StatelessWidget {
  final Constraint parentConstraint;
  final Constraint constraint;
  final Widget child;

  const ConstraintBox(
      {super.key,
      required this.parentConstraint,
      required this.constraint,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: parentConstraint.width,
      height: parentConstraint.height,
      child: Transform.translate(
        offset: Offset(constraint.xOffset, constraint.yOffset),
        child: Container(
          width: constraint.width,
          height: constraint.height,
          alignment: constraint.alignment,
          child: child,
        ),
      ),
    );
  }
}
