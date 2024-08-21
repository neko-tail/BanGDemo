/// JSON 序列化
abstract class JsonSerializable {
  Map<String, dynamic> toJson();

  factory JsonSerializable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson() has not been implemented');
  }
}
