import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

/// 自定义颜色选择器
///
/// 显示一段 [label] 文本和一个使用 [color] 的颜色指示器，
/// 点击颜色指示器弹出颜色选择器对话框，选择颜色后调用 [onColorChanged] 回调
class CustomColorPicker extends StatefulWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool readOnly;

  const CustomColorPicker({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
    this.readOnly = false,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        children: [
          Text(widget.label),
          ColorIndicator(
            hasBorder: true,
            color: widget.color,
            onSelect: () async {
              if (widget.readOnly) {
                return;
              }

              final Color newColor = await showColorPickerDialog(
                context,
                widget.color,
                enableOpacity: true,
                showColorCode: true,
                showColorName: true,
                showRecentColors: true,
                colorCodePrefixStyle: const TextStyle(
                  color: Colors.grey,
                ),
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.wheel: true,
                },
              );

              widget.onColorChanged(newColor);
            },
          )
        ],
      ),
    );
  }
}
