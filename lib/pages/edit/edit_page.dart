import 'dart:developer';

import 'package:bang_demo/data/models/cover.dart';
import 'package:bang_demo/data/providers/cover_provider.dart';
import 'package:bang_demo/data/viewmodels/cover_form_viewmodel.dart';
import 'package:bang_demo/pages/edit/widgets/cover_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 编辑页面
///
/// 编辑悬浮窗，使用 [cover] 初始化表单，当 [cover.id] 为 null 时，表示新增悬浮窗
class EditPage extends StatefulWidget {
  final Cover cover;

  const EditPage({
    super.key,
    required this.cover,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final CoverFormViewModel viewModel;

  /// 保存悬浮窗
  Future<bool> _saveCover() async {
    final ok = viewModel.validate();
    if (!ok) {
      return false;
    }

    return await Provider.of<CoverProvider>(context, listen: false)
        .saveCover(widget.cover);
  }

  /// 点击保存按钮
  void _onSaveCover() async {
    final success = await _saveCover();

    if (!success) {
      log("保存失败");
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    super.initState();
    viewModel = CoverFormViewModel(widget.cover, _formKey);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("编辑悬浮窗"),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _onSaveCover,
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: viewModel.showCover,
          child: const Icon(Icons.flash_on),
        ),
        body: Container(
          width: isPortrait ? screenWidth : screenWidth * 0.6,
          padding: const EdgeInsets.all(9),
          child: CoverForm(
            formKey: _formKey,
          ),
        ),
      ),
    );
  }
}
