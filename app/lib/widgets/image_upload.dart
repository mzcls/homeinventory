import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/media_provider.dart';
import '../providers/item_provider.dart';

class ImageUpload extends StatefulWidget {
  final int itemId;

  const ImageUpload({Key? key, required this.itemId}) : super(key: key);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      await Provider.of<MediaProvider>(context, listen: false)
          .uploadMedia(token, widget.itemId, pickedFile, itemProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera),
          label: const Text('Camera'),
        ),
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
        ),
      ],
    );
  }
}