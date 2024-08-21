import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_overlay_window/flutter_overlay_window.dart";

import "../../core/utils/json_serializable.dart";

/// 上隐悬浮窗
class Cover implements JsonSerializable {
  int? id;
  String name;
  String description;

  double borderRadius;
  Color color;

  Constraint constraint;

  CoverText text;
  CoverImage image;

  Cover({
    this.id,
    this.name = "",
    this.description = "",
    this.borderRadius = 0,
    this.color = Colors.black,
    Constraint? constraint,
    CoverText? text,
    CoverImage? image,
  })  : constraint = constraint ??
            Constraint(width: 700, height: 450, xAlign: 0, yAlign: -1),
        text = text ??
            CoverText(
                constraint: Constraint(
                    width: constraint?.width ?? 700,
                    height: constraint?.height ?? 450)),
        image = image ??
            CoverImage(
                constraint: Constraint(
                    width: constraint?.width ?? 700,
                    height: constraint?.height ?? 450));

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "borderRadius": borderRadius,
        "color": color.value,
        "constraint": constraint.toJson(),
        "text": text.toJson(),
        "image": image.toJson(),
      };

  factory Cover.fromJson(Map<String, dynamic> json) {
    return Cover(
      id: json["id"] as int?,
      name: json["name"] as String,
      description: json["description"] as String,
      borderRadius: json["borderRadius"] as double,
      color: Color(json["color"] as int),
      constraint: Constraint.fromJson(json["constraint"]),
      text: CoverText.fromJson(json["text"]),
      image: CoverImage.fromJson(json["image"]),
    );
  }

  /// 用于 SQLite 的 map
  Map<String, Object?> toSqlMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'borderRadius': borderRadius,
      'color': color.value,
      '`constraint`': jsonEncode(constraint.toJson()),
      'text': jsonEncode(text.toJson()),
      'image': jsonEncode(image.toJson()),
    };
  }

  /// 从 SQLite 的 map 创建对象
  factory Cover.fromSqlMap(Map<String, dynamic> coverMap) {
    return Cover(
      id: coverMap['id'],
      name: coverMap['name'],
      description: coverMap['description'],
      borderRadius: coverMap['borderRadius'],
      color: Color(coverMap['color']),
      constraint: Constraint.fromJson(jsonDecode(coverMap['constraint'])),
      text: CoverText.fromJson(jsonDecode(coverMap['text'])),
      image: CoverImage.fromJson(jsonDecode(coverMap['image'])),
    );
  }

  /// 等比例缩放
  void scale(double ratio) {
    borderRadius = borderRadius / ratio;
  }

  /// 深克隆
  Cover clone() {
    return Cover.fromJson(toJson());
  }
}

/// 宽高位置约束
class Constraint implements JsonSerializable {
  double width;
  double height;

  double xAlign;
  double yAlign;

  double xOffset;
  double yOffset;

  Constraint({
    this.width = 0,
    this.height = 0,
    this.xAlign = 0,
    this.yAlign = 0,
    this.xOffset = 0,
    this.yOffset = 0,
  });

  Alignment get alignment => Alignment(xAlign, yAlign);

  // 只转换能一一对应的，剩余的返回 null
  OverlayAlignment? get overlayAlignment => switch (alignment) {
        Alignment.topLeft => OverlayAlignment.topLeft,
        Alignment.topCenter => OverlayAlignment.topCenter,
        Alignment.topRight => OverlayAlignment.topRight,
        Alignment.centerLeft => OverlayAlignment.centerLeft,
        Alignment.center => OverlayAlignment.center,
        Alignment.centerRight => OverlayAlignment.centerRight,
        Alignment.bottomLeft => OverlayAlignment.bottomLeft,
        Alignment.bottomCenter => OverlayAlignment.bottomCenter,
        Alignment.bottomRight => OverlayAlignment.bottomRight,
        _ => null,
      };

  @override
  Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "xAlign": xAlign,
        "yAlign": yAlign,
        "xOffset": xOffset,
        "yOffset": yOffset,
      };

  factory Constraint.fromJson(Map<String, Object?> json) {
    return Constraint(
      width: double.parse(json["width"].toString()),
      height: double.parse(json["height"].toString()),
      xAlign: double.parse(json["xAlign"].toString()),
      yAlign: double.parse(json["yAlign"].toString()),
      xOffset: double.parse(json["xOffset"].toString()),
      yOffset: double.parse(json["yOffset"].toString()),
    );
  }

  /// 宽高与偏移量等比例缩放
  void scale(double ratio) {
    width = width / ratio;
    height = height / ratio;
    xOffset = xOffset / ratio;
    yOffset = yOffset / ratio;
  }
}

/// 悬浮窗文本
class CoverText implements JsonSerializable {
  bool enable;

  String content;
  Color color;
  int size;
  FontWeight weight;
  TextAlign align;

  Constraint constraint;

  CoverText({
    this.enable = false,
    this.content = "",
    this.color = Colors.white,
    this.size = 32,
    this.weight = FontWeight.normal,
    this.align = TextAlign.center,
    Constraint? constraint,
  }) : constraint = constraint ?? Constraint();

  @override
  Map<String, dynamic> toJson() => {
        "enable": enable,
        "content": content,
        "color": color.value,
        "size": size,
        "weight": weight.index,
        "align": align.index,
        "constraint": constraint.toJson(),
      };

  factory CoverText.fromJson(Map<String, dynamic> json) {
    return CoverText(
      enable: json["enable"] as bool,
      content: json["content"] as String,
      color: Color(json["color"] as int),
      size: json["size"] as int,
      weight: FontWeight.values[json["weight"] as int],
      align: TextAlign.values[json["align"] as int],
      constraint: Constraint.fromJson(json["constraint"]),
    );
  }
}

/// 悬浮窗图片
class CoverImage implements JsonSerializable {
  bool enable = false;

  String? path;
  double opacity;
  BoxFit fit;

  Constraint constraint;

  CoverImage({
    this.enable = false,
    this.path,
    this.opacity = 1.0,
    this.fit = BoxFit.cover,
    constraint,
  }) : constraint = constraint ?? Constraint();

  @override
  Map<String, dynamic> toJson() => {
        "enable": enable,
        "path": path,
        "opacity": opacity,
        "fix": fit.index,
        "constraint": constraint.toJson(),
      };

  factory CoverImage.fromJson(Map<String, dynamic> json) {
    return CoverImage(
      enable: json["enable"] as bool,
      path: json["path"] as String?,
      opacity: double.parse(json["opacity"].toString()),
      fit: BoxFit.values[json["fix"] as int],
      constraint: Constraint.fromJson(json["constraint"]),
    );
  }
}
