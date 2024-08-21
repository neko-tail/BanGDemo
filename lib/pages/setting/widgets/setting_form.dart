import 'package:bang_demo/data/models/setting.dart';
import 'package:bang_demo/data/viewmodels/setting_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingForm extends StatefulWidget {
  const SettingForm({
    super.key,
  });

  @override
  State<SettingForm> createState() => _SettingFormState();
}

class _SettingFormState extends State<SettingForm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingFormViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: viewModel.formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  const Text("悬浮窗自启："),
                  Switch(
                    value: viewModel.setting.autoStart,
                    onChanged: (bool value) {
                      setState(() {
                        viewModel.setting.autoStart = value;
                      });
                    },
                  ),
                ],
              ),
              const Divider(),
              Text("悬浮窗手势事件", style: Theme.of(context).textTheme.headlineSmall),
              GestureEventDropDownMenu(
                label: "单击",
                event: viewModel.setting.gesture.tap,
                onSelected: (event) {
                  setState(() {
                    viewModel.setting.gesture.tap = event!;
                  });
                },
              ),
              GestureEventDropDownMenu(
                label: "双击",
                event: viewModel.setting.gesture.doubleTap,
                onSelected: (event) {
                  setState(() {
                    viewModel.setting.gesture.doubleTap = event!;
                  });
                },
              ),
              GestureEventDropDownMenu(
                label: "三击",
                event: viewModel.setting.gesture.tripleTap,
                onSelected: (event) {
                  setState(() {
                    viewModel.setting.gesture.tripleTap = event!;
                  });
                },
              ),
              // 长按关闭悬浮窗之后，再次打开，悬浮窗长按事件会失效，暂时不支持
              // GestureEventDropDownMenu(
              //   label: "长按",
              //   event: viewModel.setting.gesture.longPress,
              //   onSelected: (event) {
              //     setState(() {
              //       viewModel.setting.gesture.longPress = event!;
              //     });
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }
}

class GestureEventDropDownMenu extends StatelessWidget {
  final String label;
  final GestureEvent event;
  final void Function(GestureEvent?) onSelected;

  const GestureEventDropDownMenu({
    super.key,
    required this.label,
    required this.event,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownMenu<GestureEvent>(
        initialSelection: event,
        label: Text(label),
        onSelected: onSelected,
        inputDecorationTheme: const InputDecorationTheme(
          border: null,
        ),
        dropdownMenuEntries:
            GestureEvent.values.map<DropdownMenuEntry<GestureEvent>>((event) {
          return DropdownMenuEntry(value: event, label: event.label);
        }).toList(),
      ),
    );
  }
}
