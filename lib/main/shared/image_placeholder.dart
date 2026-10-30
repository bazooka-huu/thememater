import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_drop/flutter_file_drop.dart';

class ImagePlaceholder extends StatefulWidget {
  const ImagePlaceholder({
    super.key,
    required this.aspectRatio,
    required this.sizeString,
    required this.onTap,
    required this.onDropFile
  });
  final double aspectRatio;
  final String sizeString;
  final Function() onTap;
  final Function(Uint8List) onDropFile;

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder> {
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
      child: CupertinoButton(
        padding: .zero,
        onPressed: widget.onTap,
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            height: .infinity,
            width: .infinity,
            alignment: .center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(12.0),
              border: _hovering ? Border.all(
                color: Colors.lightBlue,
                width: 1.5
              ) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1,
                  blurStyle: .outer
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: Colors.black,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(widget.sizeString,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: .w400,
                    fontSize: 12
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
