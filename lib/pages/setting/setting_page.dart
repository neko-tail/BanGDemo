import 'dart:developer';

import 'package:bang_demo/pages/setting/widgets/setting_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/setting.dart';
import '../../data/providers/setting_provider.dart';
import '../../data/viewmodels/setting_form_viewmodel.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({
    super.key,
  });

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SettingFormViewModel viewModel;
  late final Setting setting;

  Future<bool> _saveSetting() async {
    final ok = viewModel.validate();
    if (!ok) {
      return false;
    }

    return await Provider.of<SettingProvider>(context, listen: false)
        .updateSetting(setting);
  }

  /// 点击保存按钮
  void _onSaveSetting() async {
    final success = await _saveSetting();

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
    final provider = Provider.of<SettingProvider>(context, listen: false);
    setting = provider.setting!;
    viewModel = SettingFormViewModel(setting, _formKey);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _onSaveSetting,
                );
              },
            ),
          ],
        ),
        body: Container(
          width: isPortrait ? screenWidth : screenWidth * 0.6,
          padding: const EdgeInsets.all(16),
          child: const SettingForm(),
        ),
      ),
    );
  }
}
