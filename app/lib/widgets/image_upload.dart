import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Import flutter_image_compress
import 'dart:io'; // For File
import 'dart:typed_data'; // For Uint8List

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
      // Read original image bytes
      Uint8List? imageBytes = await pickedFile.readAsBytes();

      if (imageBytes != null) {
        // Compress image
        Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
          imageBytes,
          minHeight: 1920, // Max height
          minWidth: 1080,  // Max width
          quality: 80,     // Compression quality
          rotate: 0,       // No rotation
        );

        if (compressedBytes != null) {
          final token = Provider.of<AuthProvider>(context, listen: false).token!;
          final itemProvider = Provider.of<ItemProvider>(context, listen: false);
          await Provider.of<MediaProvider>(context, listen: false)
              .uploadMedia(token, widget.itemId, compressedBytes, pickedFile.name, itemProvider);
        }
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickVideo(source: source);
    if (pickedFile != null) {
      // For video, we upload directly without compression for now
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      // Pass XFile directly for video, MediaProvider will handle it
      await Provider.of<MediaProvider>(context, listen: false)
          .uploadMedia(token, widget.itemId, pickedFile, pickedFile.name, itemProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          label: const Text('拍照', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('相册', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _pickVideo(ImageSource.camera),
          icon: const Icon(Icons.videocam),
          label: const Text('录像', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _pickVideo(ImageSource.gallery),
          icon: const Icon(Icons.video_library),
          label: const Text('视频', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}