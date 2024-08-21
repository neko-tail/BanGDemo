import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  final String buttonText;
  final String? imageUrl;
  final String noSelectedLabel;
  final ValueChanged<String?> onImageChanged;
  final bool readOnly;

  const CustomImagePicker({
    super.key,
    required this.buttonText,
    required this.imageUrl,
    this.noSelectedLabel = '未选择图片',
    required this.onImageChanged,
    this.readOnly = false,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  String? _imageUrl;

  /// 可能未选择图片
  void _pickImage() async {
    if (widget.readOnly) {
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageUrl = pickedFile?.path;
    });

    widget.onImageChanged(_imageUrl);
  }

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        children: [
          TextButton(onPressed: _pickImage, child: Text(widget.buttonText)),
          _imageUrl == null
              ? Text(widget.noSelectedLabel)
              : Image.file(File(_imageUrl!)),
        ],
      ),
    );
  }
}
