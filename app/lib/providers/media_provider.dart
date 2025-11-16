import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/media_service.dart';
import 'item_provider.dart';

class MediaProvider with ChangeNotifier {
  final MediaService _mediaService = MediaService();

  Future<void> uploadMedia(String token, int itemId, XFile file, ItemProvider itemProvider) async {
    try {
      final response = await _mediaService.uploadMedia(token, itemId, file);
      if (response.statusCode == 200) {
        // Refresh the item details to show the new media
        await itemProvider.fetchItem(token, itemId);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> deleteMedia(String token, int mediaId, int itemId, ItemProvider itemProvider) async {
    try {
      final response = await _mediaService.deleteMedia(token, mediaId);
      if (response.statusCode == 200) {
        // Refresh the item details to show the updated media list
        await itemProvider.fetchItem(token, itemId);
        return true;
      }
      return false;
    } catch (e) {
      // Handle error
      return false;
    }
  }
}