import '../../core/utils/json_serializable.dart';

/// 悬浮窗与主界面通信的消息
class OverlayMsg implements JsonSerializable {
  final MsgType type;

  /// 消息数据，JSON 格式
  final Map<String, dynamic>? data;

  OverlayMsg(this.type, {this.data});

  @override
  Map<String, dynamic> toJson() => {
        "type": type.index,
        "data": data,
      };

  factory OverlayMsg.fromJson(Map<String, dynamic> json) {
    return OverlayMsg(
      MsgType.values[json["type"] as int],
      data: json["data"],
    );
  }
}

/// 消息类型
enum MsgType {
  /// 显示悬浮窗
  show,

  /// 关闭悬浮窗
  close,

  /// 传递设置
  setting,
}
