import 'dart:convert';

import 'package:bang_demo/core/utils/json_serializable.dart';

/// app 设置
class Setting implements JsonSerializable {
  int id;

  /// 悬浮窗自启动
  bool autoStart;

  /// 悬浮窗手势
  Gesture gesture;

  Setting({
    required this.id,
    required this.autoStart,
    required this.gesture,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json["id"] as int,
      autoStart: json["autoStart"] as bool,
      gesture: Gesture.fromJson(json["gesture"]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "autoStart": autoStart,
      "gesture": gesture.toJson(),
    };
  }

  factory Setting.fromSqlMap(Map<String, dynamic> json) {
    return Setting(
      id: json["id"] as int,
      autoStart: json["autoStart"] as int != 0,
      gesture: Gesture.fromJson(jsonDecode(json["gesture"])),
    );
  }

  Map<String, dynamic> toSqlMap() {
    return {
      "id": id,
      "autoStart": autoStart ? 1 : 0,
      "gesture": jsonEncode(gesture.toJson()),
    };
  }
}

/// 手势
class Gesture implements JsonSerializable {
  GestureEvent tap;
  GestureEvent doubleTap;
  GestureEvent tripleTap;
  GestureEvent longPress;

  Gesture({
    this.tap = GestureEvent.none,
    this.doubleTap = GestureEvent.none,
    this.tripleTap = GestureEvent.none,
    this.longPress = GestureEvent.none,
  });

  factory Gesture.fromJson(Map<String, dynamic> json) {
    return Gesture(
      tap: GestureEvent.values[json["tap"] as int],
      doubleTap: GestureEvent.values[json["doubleTap"] as int],
      tripleTap: GestureEvent.values[json["tripleTap"] as int],
      longPress: GestureEvent.values[json["longPress"] as int],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "tap": tap.index,
        "doubleTap": doubleTap.index,
        "tripleTap": tripleTap.index,
        "longPress": longPress.index,
      };
}

/// 手势对应的事件
enum GestureEvent {
  /// do nothing
  none("无动作"),

  /// 重置悬浮窗位置
  reset("重置位置"),

  /// 关闭悬浮窗
  close("关闭悬浮窗"),
  ;

  const GestureEvent(this.label);

  final String label;
}
