import 'package:flutter/cupertino.dart';

import '../models/setting.dart';

class SettingFormViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey;
  final Setting setting;

  SettingFormViewModel(this.setting, this.formKey);

  bool validate() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    formKey.currentState!.save();

    return true;
  }
}
