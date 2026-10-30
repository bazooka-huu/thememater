import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_drop/flutter_file_drop.dart';

class ImageItem extends StatefulWidget {
  const ImageItem({
    super.key,
    required this.data,
    required this.isSelect,
    required this.aspectRatio,
    required this.onDelete,
    required this.onChange,
    required this.onSelect,
    required this.onDropFile,
  });

  final Uint8List data;
  final bool isSelect;
  final double aspectRatio;
  final Function() onDelete;
  final Function() onChange;
  final Function(bool) onSelect;
  final Function(Uint8List) onDropFile;

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      constraints: DropConstraints(
        allowedMimeTypes: {'image/*'},
        maxFiles: 1,
        maxFileSizeBytes: 20 * 1024 * 1024,
      ),
      onEnter: (preview) => setState(() => _hovering = true),
      onLeave: () => setState(() => _hovering = false),
      onDrop: (result) async {
        final List<Uint8List> files = [];
        for (final entry in result.items) {
          if (!entry.accepted) {
            debugPrint('Rejected: ${entry.reasons}');
            continue;
          }
          final item = entry.item;

          if (item is DropFile) {
            final data = await item.readAsBytes();
            files.add(data);
          } else if (item is DropString) {
            debugPrint('${item.mimeType}: ${item.value}');
          }
        }
        if (files.isNotEmpty) {
          widget.onDropFile(files.first);
        }
      },
      child:  AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onChange,
              child: ClipPath(
                child: Image.memory(
                  widget.data,
                  fit: .fill,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            left: 8,
            child: Row(
              children: [
                CupertinoCheckbox(
                  value: widget.isSelect,
                  onChanged: (value) {
                    widget.onSelect(value ?? false);
                  }
                ),
                Spacer(),
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CupertinoButton(
                    color: Colors.redAccent,
                    borderRadius: .circular(100),
                    padding: .zero,
                    onPressed: widget.onDelete,
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 10,
                      color: Colors.white,
                    )
                  ),
                ),
              ],
            ),
          )
        ],
      )
    )
    );
  }
}