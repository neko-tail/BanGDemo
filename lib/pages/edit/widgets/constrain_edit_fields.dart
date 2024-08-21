import 'package:bang_demo/core/utils/form_field_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/cover.dart';

/// 自定义约束表单
///
/// 用于编辑 [Constraint] 的表单
///
/// [enable] 为是否启用表单
///
/// [constraint] 为需要编辑的 [Constraint] 对象
///
/// [onCheckFail] 为校验失败时执行的函数
class ConstraintEditFields extends StatefulWidget {
  final Constraint constraint;
  final FormFieldValidator<String> validator;
  final bool hideWH;
  final bool readOnly;

  const ConstraintEditFields({
    super.key,
    required this.constraint,
    required this.validator,
    this.hideWH = false,
    this.readOnly = false,
  });

  @override
  State<ConstraintEditFields> createState() => _ConstraintEditFormState();
}

class _ConstraintEditFormState extends State<ConstraintEditFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.hideWH)
          TextFormField(
            decoration: simpleLabel("宽度"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            initialValue: widget.constraint.width.toInt().toString(),
            readOnly: widget.readOnly,
            validator: widget.validator,
            onSaved: (value) {
              widget.constraint.width = double.parse(value!);
            },
          ),
        if (!widget.hideWH)
          TextFormField(
            decoration: simpleLabel("高度"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            initialValue: widget.constraint.height.toInt().toString(),
            readOnly: widget.readOnly,
            validator: widget.validator,
            onSaved: (value) {
              widget.constraint.height = double.parse(value!);
            },
          ),
        TextFormField(
          decoration: simpleLabel("x坐标偏移"),
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$')),
          ],
          initialValue: widget.constraint.xOffset.toInt().toString(),
          readOnly: widget.readOnly,
          validator: widget.validator,
          onSaved: (value) {
            if (value == '-') {
              value = '0';
            }
            widget.constraint.xOffset = double.parse(value!);
          },
        ),
        TextFormField(
          decoration: simpleLabel("y坐标偏移"),
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$')),
          ],
          initialValue: widget.constraint.yOffset.toInt().toString(),
          readOnly: widget.readOnly,
          validator: widget.validator,
          onSaved: (value) {
            if (value == '-') {
              value = '0';
            }
            widget.constraint.yOffset = double.parse(value!);
          },
        ),
        Row(
          children: [
            const Text("水平方向："),
            for ((String, double) i in [("左对齐", -1), ("居中", 0), ("右对齐", 1)])
              Row(
                children: [
                  Radio(
                    value: i.$2,
                    groupValue: widget.constraint.xAlign,
                    onChanged: (value) {
                      if (widget.readOnly) {
                        return;
                      }
                      setState(() {
                        if (value == null) {
                          return;
                        }
                        widget.constraint.xAlign = value;
                      });
                    },
                  ),
                  Text(i.$1),
                ],
              ),
          ],
        ),
        Row(
          children: [
            const Text("垂直方向："),
            for ((String, double) i in [("上对齐", -1), ("居中", 0), ("下对齐", 1)])
              Row(
                children: [
                  Radio(
                    value: i.$2,
                    groupValue: widget.constraint.yAlign,
                    onChanged: (value) {
                      setState(() {
                        if (widget.readOnly) {
                          return;
                        }
                        if (value == null) {
                          return;
                        }
                        widget.constraint.yAlign = value;
                      });
                    },
                  ),
                  Text(i.$1),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
