import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 导入缓存库
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/media_provider.dart';
import '../widgets/image_upload.dart';
import 'edit_item_page.dart';
import '../config.dart';
import '../models/item_media.dart'; // Import ItemMedia

class ItemDetailPage extends StatefulWidget {
  final int itemId;
  final bool includeDeleted; // New parameter

  const ItemDetailPage({Key? key, required this.itemId, this.includeDeleted = false}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  int _mediaPageIndex = 0; // Track current media page index

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ItemProvider>(context, listen: false)
        .fetchItem(authProvider.token!, widget.itemId, includeDeleted: widget.includeDeleted)
        .then((_) {
      // Pre-cache full images after fetching item details
      if (mounted) {
        final item = Provider.of<ItemProvider>(context, listen: false).selectedItem;
        if (item != null) {
          for (var media in item.media) {
            if (media.fileType == 'image' && media.fileUrl.isNotEmpty) {
              final fullUrl = '${Config.apiBaseUrl}${media.fileUrl.replaceAll('/uploads//uploads/', '/uploads/')}';
              precacheImage(CachedNetworkImageProvider(fullUrl), context);
            }
          }
        }
      }
    });
  }

  void _showFullMediaViewer(BuildContext context, List<ItemMedia> mediaList, int initialIndex) {
    PageController pageController = PageController(initialPage: initialIndex);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(), // Click again to dismiss
              child: Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: mediaList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _mediaPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final media = mediaList[index];
                      final correctedFullUrl = media.fileUrl.replaceAll('/uploads//uploads/', '/uploads/');
                      final fullUrl = '${Config.apiBaseUrl}$correctedFullUrl';

                      return Center(
                        child: media.fileType == 'image'
                            ? InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.8,
                                maxScale: 4,
                                child: CachedNetworkImage(
                                  imageUrl: fullUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                                ),
                              )
                            : Container(
                                color: Colors.black,
                                child: const Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Text(
                      '${_mediaPageIndex + 1} / ${mediaList.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateQuantity(Item item, int change) {
    if (widget.includeDeleted) return; // Disable for deleted items

    final newQuantity = item.quantity + change;
    if (newQuantity <= 0) {
      _showDeleteConfirmationDialog(item);
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      itemProvider.updateItem(
        authProvider.token!,
        item.id,
        item.name,
        item.category?.categoryId,
        item.location,
        newQuantity,
        item.warehouseId,
      );
    }
  }

  void _showDeleteConfirmationDialog(Item item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('物品数量已为0，您确定要删除物品 "${item.name}" 吗？'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('删除', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final itemProvider = Provider.of<ItemProvider>(context, listen: false);
              final result = await itemProvider.deleteItem(
                authProvider.token!,
                item.id,
                item.warehouseId,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
                if (result['success']) {
                  Navigator.of(context).pop(); // Go back to item list
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _restoreItem(Item item) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final success = await itemProvider.restoreItem(authProvider.token!, item.id, item.warehouseId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? '物品已恢复' : '物品恢复失败')),
      );
      if (success) {
        Navigator.of(context).pop(); // Go back to deleted items list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final item = itemProvider.selectedItem;

    return Scaffold(
      appBar: AppBar(
        title: Text(item?.name ?? '物品详情'),
        actions: [
          if (item != null && !widget.includeDeleted) // Only show edit for non-deleted items
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditItemPage(item: item),
                  ),
                );
              },
            ),
          if (item != null && widget.includeDeleted) // Show restore for deleted items
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () => _restoreItem(item),
            ),
        ],
      ),
      body: item == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.includeDeleted)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        '此物品已删除',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  Text('名称: ${item.name}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text('分类: ${item.category?.name ?? 'N/A'}'),
                  const SizedBox(height: 10),
                  Text('位置: ${item.location ?? 'N/A'}'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('数量: ', style: TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: widget.includeDeleted ? null : () => _updateQuantity(item, -1), // Disable if deleted
                      ),
                      Text('${item.quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: widget.includeDeleted ? null : () => _updateQuantity(item, 1), // Disable if deleted
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!widget.includeDeleted) // Hide upload for deleted items
                    ImageUpload(itemId: item.id),
                  const SizedBox(height: 20),
                  const Text('媒体:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  item.media.isEmpty
                      ? const Text('没有找到媒体文件。')
                      : Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: item.media.length,
                            itemBuilder: (context, index) {
                              final media = item.media[index];
                              final correctedThumbUrl = (media.thumbnailUrl ?? media.fileUrl).replaceAll('/uploads//uploads/', '/uploads/');
                              final thumbUrl = '${Config.apiBaseUrl}$correctedThumbUrl';
                              // final correctedFullUrl = media.fileUrl.replaceAll('/uploads//uploads/', '/uploads/');
                              // final fullUrl = '${Config.apiBaseUrl}$correctedFullUrl';

                              return GridTile(
                                child: InkWell(
                                  onTap: () {
                                    _showFullMediaViewer(context, item.media, index); // Pass all media and initial index
                                  },
                                  onLongPress: widget.includeDeleted ? null : () { // Disable long press for deleted items
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text('确认删除'),
                                          content: const Text('您确定要删除这个媒体文件吗？此操作不可撤销。'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('取消'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('删除', style: TextStyle(color: Colors.red)),
                                              onPressed: () async {
                                                Navigator.of(ctx).pop();
                                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                                final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
                                                final itemProvider = Provider.of<ItemProvider>(context, listen: false);

                                                final success = await mediaProvider.deleteMedia(
                                                  authProvider.token!,
                                                  media.id,
                                                  item.id,
                                                  itemProvider,
                                                );

                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(success ? '删除成功' : '删除失败'),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: media.fileType == 'image'
                                      ? CachedNetworkImage(
                                          imageUrl: thumbUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40),
                                        )
                                      : Container(
                                          color: Colors.black,
                                          child: const Icon(
                                            Icons.videocam,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
