import 'package:bang_demo/data/models/cover.dart';
import 'package:bang_demo/data/viewmodels/cover_form_viewmodel.dart';
import 'package:bang_demo/pages/edit/widgets/cover_image_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cover_basic_panel.dart';
import 'cover_text_panel.dart';

/// 编辑悬浮窗的表单
///
/// 用于编辑 [Cover] 的表单
///
/// [formKey] 为表单的 [GlobalKey]，用于校验和保存表单
///
/// [cover] 为需要编辑的 [Cover] 对象
class CoverForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const CoverForm({
    super.key,
    required this.formKey,
  });

  @override
  State<CoverForm> createState() => CoverFormState();
}

class CoverFormState extends State<CoverForm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CoverFormViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: widget.formKey,
          child: ListView(
            children: [
              ExpansionPanelList(
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                materialGapSize: 0,
                children: [
                  CustomExpansionPanel(
                    isOpen: viewModel.basicIsOpen,
                    title: "基础信息",
                    children: [
                      const CoverBasicPanel(),
                    ],
                  ),
                  CustomExpansionPanel(
                    isOpen: viewModel.textIsOpen,
                    title: '文本',
                    children: [
                      const CoverTextPanel(),
                    ],
                  ),
                  CustomExpansionPanel(
                    isOpen: viewModel.imageIsOpen,
                    title: '图片',
                    children: [
                      const CoverImagePanel(),
                    ],
                  ),
                ],
                expansionCallback: (i, isOpen) {
                  setState(() {
                    viewModel.setOpen(i, isOpen);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 自定义展开面板
///
/// 仅配置了一些自定义样式
class CustomExpansionPanel extends ExpansionPanel {
  /// 创建 [CustomExpansionPanel]
  ///
  /// [isOpen] 控制是否展开
  ///
  /// [title] 为标题文本
  ///
  /// [children] 为展开面板中的内容，放于 `Column` 中
  CustomExpansionPanel({
    required bool isOpen,
    required String title,
    required List<Widget> children,
  }) : super(
          isExpanded: isOpen,
          canTapOnHeader: true,
          headerBuilder: (context, isOpen) {
            return ListTile(
              title: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          },
          body: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        );
}
