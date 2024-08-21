import 'dart:io';

import 'package:bang_demo/data/viewmodels/cover_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/form_field_util.dart';
import '../../../widgets/custom_image_picker.dart';
import 'constrain_edit_fields.dart';

class CoverImagePanel extends StatefulWidget {
  const CoverImagePanel({
    super.key,
  });

  @override
  State<CoverImagePanel> createState() => _CoverImagePanelState();
}

class _CoverImagePanelState extends State<CoverImagePanel> {
  String? _notEmptyValidator(String? value) {
    final provider = Provider.of<CoverFormViewModel>(context, listen: false);

    if (!provider.cover.image.enable) {
      return null;
    }

    if (value == null || value.isEmpty) {
      provider.imageIsOpen = true;
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
                  value: viewModel.cover.image.enable,
                  onChanged: (bool value) {
                    setState(() {
                      viewModel.cover.image.enable = value;
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              decoration: moreInfoLabel(context, "宽度", "图片宽度最大为悬浮窗宽度，超出部分无效"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              initialValue:
                  viewModel.cover.image.constraint.width.toInt().toString(),
              readOnly: !viewModel.cover.image.enable,
              validator: _notEmptyValidator,
              onSaved: (value) {
                viewModel.cover.image.constraint.width = double.parse(value!);
              },
            ),
            TextFormField(
              decoration: moreInfoLabel(context, "高度", "图片高度最大为悬浮窗高度，超出部分无效"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              initialValue:
                  viewModel.cover.image.constraint.height.toInt().toString(),
              readOnly: !viewModel.cover.image.enable,
              validator: _notEmptyValidator,
              onSaved: (value) {
                viewModel.cover.image.constraint.height = double.parse(value!);
              },
            ),
            ConstraintEditFields(
              readOnly: !viewModel.cover.image.enable,
              constraint: viewModel.cover.image.constraint,
              validator: _notEmptyValidator,
              hideWH: true,
            ),
            Text("透明度：${viewModel.cover.image.opacity}"),
            Slider(
                value: viewModel.cover.image.opacity * 100,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  if (!viewModel.cover.image.enable) {
                    return;
                  }

                  setState(() {
                    viewModel.cover.image.opacity = value / 100;
                  });
                }),
            Wrap(
              children: [
                const Text("填充方式："),
                Wrap(
                  children: [
                    for (var i in [
                      ("填充", BoxFit.fill),
                      ("适应", BoxFit.contain),
                      ("拉伸", BoxFit.cover),
                      ("填充宽度", BoxFit.fitWidth),
                      ("填充高度", BoxFit.fitHeight),
                      ("缩放", BoxFit.scaleDown),
                    ])
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio(
                            value: i.$2,
                            groupValue: viewModel.cover.image.fit,
                            onChanged: (value) {
                              if (!viewModel.cover.image.enable) {
                                return;
                              }

                              setState(() {
                                if (value == null) {
                                  return;
                                }
                                viewModel.cover.image.fit = value;
                              });
                            },
                          ),
                          Text(i.$1),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            CustomImagePicker(
              buttonText: "选择图片",
              imageUrl: viewModel.cover.image.path,
              readOnly: !viewModel.cover.image.enable,
              onImageChanged: (path) async {
                if (path != null) {
                  final imageFile = File(path);
                  final image =
                      await decodeImageFromList(imageFile.readAsBytesSync());
                  viewModel.cover.image.path = path;
                  viewModel.cover.image.constraint.width =
                      image.width.toDouble();
                  viewModel.cover.image.constraint.height =
                      image.height.toDouble();
                } else {
                  viewModel.cover.image.path = null;
                }
              },
            ),
          ],
        );
      },
    );
  }
}
