import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/form_field_util.dart';
import '../../../data/viewmodels/cover_form_viewmodel.dart';
import '../../../widgets/custom_color_picker.dart';
import 'constrain_edit_fields.dart';

/// 编辑悬浮窗的文本
class CoverTextPanel extends StatefulWidget {
  const CoverTextPanel({super.key});

  @override
  State<CoverTextPanel> createState() => _CoverTextExpansionPanelState();
}

class _CoverTextExpansionPanelState extends State<CoverTextPanel> {
  String? _notEmptyValidator(String? value) {
    final provider = Provider.of<CoverFormViewModel>(context, listen: false);
    if (!provider.cover.text.enable) {
      return null;
    }

    if (value == null || value.isEmpty) {
      provider.setTextIsOpen(true);
      return "此处不能为空";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoverFormViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("是否启用："),
                Switch(
                  value: viewModel.cover.text.enable,
                  onChanged: (bool value) {
                    setState(() {
                      viewModel.cover.text.enable = value;
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              decoration: simpleLabel("文本"),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              initialValue: viewModel.cover.text.content,
              readOnly: !viewModel.cover.text.enable,
              validator: _notEmptyValidator,
              onSaved: (value) {
                viewModel.cover.text.content = value!;
              },
            ),
            TextFormField(
              decoration: simpleLabel("字体大小"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              initialValue: viewModel.cover.text.size.toString(),
              readOnly: !viewModel.cover.text.enable,
              validator: _notEmptyValidator,
              onSaved: (value) {
                viewModel.cover.text.size = int.parse(value!);
              },
            ),
            CustomColorPicker(
              label: "字体颜色：",
              color: viewModel.cover.text.color,
              readOnly: !viewModel.cover.text.enable,
              onColorChanged: (color) {
                setState(() {
                  viewModel.cover.text.color = color;
                });
              },
            ),
            Text("字体粗细：${viewModel.cover.text.weight.value}"),
            Slider(
              min: 0,
              max: 8,
              value: viewModel.cover.text.weight.index.toDouble(),
              onChanged: (value) {
                if (!viewModel.cover.text.enable) {
                  return;
                }

                setState(() {
                  viewModel.cover.text.weight =
                      FontWeight.values[value.round()];
                });
              },
            ),
            Row(
              children: [
                const Text("文本对齐："),
                for (var i in [
                  ("左对齐", TextAlign.left),
                  ("居中", TextAlign.center),
                  ("右对齐", TextAlign.right)
                ])
                  Row(
                    children: [
                      Radio(
                        value: i.$2,
                        groupValue: viewModel.cover.text.align,
                        onChanged: (value) {
                          if (!viewModel.cover.text.enable) {
                            return;
                          }

                          setState(() {
                            if (value == null) {
                              return;
                            }
                            viewModel.cover.text.align = value;
                          });
                        },
                      ),
                      Text(i.$1),
                    ],
                  ),
              ],
            ),
            ConstraintEditFields(
              readOnly: !viewModel.cover.text.enable,
              constraint: viewModel.cover.text.constraint,
              validator: _notEmptyValidator,
              hideWH: true,
            ),
          ],
        );
      },
    );
  }
}
