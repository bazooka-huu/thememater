import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_file_drop/flutter_file_drop.dart';
import 'package:theme_maker/models/icon_item.dart';
import 'package:path/path.dart' as path;

class IconsPlaceholder extends StatefulWidget {
  final Function(List<IconItem>) onDropFiles;
  const IconsPlaceholder({super.key, required this.onDropFiles});

  @override
  State<IconsPlaceholder> createState() => _IconsPlaceholderState();
}

class _IconsPlaceholderState extends State<IconsPlaceholder> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      constraints: DropConstraints(
        allowedMimeTypes: {'image/*'},
        maxFileSizeBytes: 20 * 1024 * 1024,
      ),
      onEnter: (preview) => setState(() => _hovering = true),
      onLeave: () => setState(() => _hovering = false),
      onDrop: (result) async {
        final List<IconItem> files = [];
        for (final entry in result.items) {
          if (!entry.accepted) {
            debugPrint('Rejected: ${entry.reasons}');
            continue;
          }
          final item = entry.item;

          if (item is DropFile) {
            final id = int.tryParse(path.basenameWithoutExtension(item.name ?? "")) ?? -1;
            final data = await item.readAsBytes();
            files.add(
              IconItem(id: id, file: data)
            );
          } else if (item is DropString) {
            debugPrint('${item.mimeType}: ${item.value}');
          }
        }
        files.removeWhere((e) => e.id < 0);
        if (files.isNotEmpty) {
          widget.onDropFiles(files);
        }
      },
      child: Container(
        padding: .all(32),
        width: double.infinity,
        margin: .all(1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: .circular(20),
          border: _hovering ? .all(
            color: Colors.lightBlue,
            width:  1.5,
            style: .solid
          ) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 1,
              blurStyle: .inner
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .center,
          children: [
            Text("Drop icon images",
              style: TextStyle(
                color: Colors.black,
                fontWeight: .w600,
                fontSize: 16
              )
            ),
            SizedBox(height: 8),
            Text(
              "Format: \"1.png\",\"2.png\",\"3.png\"... \nSize: 384x384",
                textAlign: .center,
                style: TextStyle(
                color: Colors.grey,
                fontWeight: .w400,
                fontSize: 12
              )
            )
          ]
        ),
      ),
    );
  }
}
