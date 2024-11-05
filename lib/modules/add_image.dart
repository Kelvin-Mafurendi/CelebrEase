// add_image.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';

class AddImage extends StatefulWidget {
  final double size;
  final String? defaultImageUrl;
  final BoxShape shape;
  final bool showAddIcon;
  final Color? backgroundColor;
  final Widget? placeholder;
  final IconData? addIcon;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;
  final double? iconSize;
  final String dataType;
  final String fieldName;
  final void Function(File)? onImageSelected;
  
  const AddImage({
    super.key,
    this.size = 100,
    this.defaultImageUrl,
    this.shape = BoxShape.circle,
    this.showAddIcon = true,
    this.backgroundColor,
    this.placeholder,
    this.addIcon,
    this.iconColor,
    this.iconPadding,
    this.iconSize,
    required this.dataType,
    required this.fieldName,
    this.onImageSelected,
  });

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  Future<void> getImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: false);

      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        File image = File(result.files.first.path!);
        if (mounted) {
          Provider.of<ChangeManager>(context, listen: false)
              .setImage(widget.dataType, widget.fieldName, image);
          
          if (widget.onImageSelected != null) {
            widget.onImageSelected!(image);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // You might want to show a snackbar or dialog here
    }
  }

  Widget _buildImageContent(ChangeManager changeManager) {
    final currentImage = changeManager.getImage(widget.dataType, widget.fieldName);
    final hasDefaultUrl = widget.defaultImageUrl != null && widget.defaultImageUrl!.isNotEmpty;
    
    if (currentImage != null) {
      return Image.file(
        currentImage,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (hasDefaultUrl) {
      return CachedNetworkImage(
        imageUrl: widget.defaultImageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: widget.placeholder ?? 
            Icon(Icons.image, color: Colors.grey, size: widget.size * 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeManager>(
      builder: (context, changeManager, child) {
        return Stack(
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: widget.shape,
                color: widget.backgroundColor ?? Colors.grey[200],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImageContent(changeManager),
            ),
            if (widget.showAddIcon)
              Positioned(
                right: widget.size * 0.1,
                bottom: 5,
                child: InkWell(
                  onTap: () => getImage(context),
                  child: Container(
                    padding: widget.iconPadding ?? const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Icon(
                      widget.addIcon ?? 
                          FluentSystemIcons.ic_fluent_camera_add_regular,
                      color: widget.iconColor ?? Colors.white,
                      size: widget.iconSize ?? 24,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}