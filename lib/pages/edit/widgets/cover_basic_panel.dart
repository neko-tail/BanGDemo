import 'package:bang_demo/data/viewmodels/cover_form_viewmodel.dart';
import 'package:bang_demo/pages/edit/widgets/constrain_edit_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/form_field_util.dart';
import '../../../widgets/custom_color_picker.dart';

/// 编辑悬浮窗的基础信息
class CoverBasicPanel extends StatefulWidget {
  const CoverBasicPanel({super.key});

  @override
  State<CoverBasicPanel> createState() => _CoverBasicPanelState();
}

class _CoverBasicPanelState extends State<CoverBasicPanel> {
  /// 非空验证
  String? _notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      Provider.of<CoverFormViewModel>(context, listen: false).basicIsOpen =
          true;
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
            TextFormField(
              decoration: simpleLabel("名称"),
              initialValue: viewModel.cover.name,
              validator: _notEmptyValidator,
              onSaved: (value) {
                viewModel.cover.name = value!;
              },
            ),
            TextFormField(
              decoration: simpleLabel("描述"),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              initialValue: viewModel.cover.description,
              onSaved: (value) {
                viewModel.cover.description = value!;
              },
            ),
            TextFormField(
              decoration: moreInfoLabel(
                  context,
                  "矩形圆角",
                  "最大为悬浮窗窄边长度的一半，超出部分无效，如：\n"
                      "若悬浮窗长度为 700，宽度为 400\n"
                      "则圆角最大为 200\n"
                      "设置为 300 时，实际效果为 200"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              initialValue: viewModel.cover.borderRadius.toString(),
              validator: _notEmptyValidator,
              onSaved: (value) {
                viewModel.cover.borderRadius = double.parse(value!);
              },
            ),
            CustomColorPicker(
              label: "背景颜色：",
              color: viewModel.cover.color,
              onColorChanged: (color) {
                setState(() {
                  viewModel.cover.color = color;
                });
              },
            ),
            ConstraintEditFields(
              constraint: viewModel.cover.constraint,
              validator: _notEmptyValidator,
            ),
          ],
        );
      },
    );
  }
}
