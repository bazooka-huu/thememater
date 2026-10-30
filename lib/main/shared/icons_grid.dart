import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_drop/flutter_file_drop.dart';
import 'package:theme_maker/models/icon_info.dart';
import 'package:theme_maker/models/icon_item.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';

class IconsGrid extends StatefulWidget {
  final List<IconItem> items;
  final Function(List<IconItem>) onDropFiles;
  final Function(int) onRemoveItem;
  const IconsGrid({
    super.key,
    required this.items,
    required this.onDropFiles,
    required this.onRemoveItem
  });

  @override
  State<IconsGrid> createState() => _IconsGridState();
}

class _IconsGridState extends State<IconsGrid> {
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
      child: SizedBox(
        height: 400,
        child: GridView.builder(
          scrollDirection: .horizontal,
          padding: const EdgeInsets.all(4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.625,
          ),
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final info = IconInfo.defaultIcons.firstWhereOrNull((e) => e.id == item.id);
            return LayoutBuilder(
              builder: (context, constraints) {
                final r = min(constraints.maxWidth / 200, constraints.maxHeight / 125);
                return Container(
                  alignment: Alignment.center,
                  padding: .all(8 * r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 1 * r,
                        blurStyle: .outer
                      )
                    ],
                    borderRadius: BorderRadius.circular(12 * r),
                  ),
                  child: Stack(
                    children: [
                      Column(
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              mainAxisAlignment: .center,
                              children: [
                                Image.asset(
                                    "assets/resources/default_icons/${item.id}.png",
                                    height: 48 * r,
                                    width: 48 * r,
                                    fit: .cover
                                ),
                                SizedBox(width: 4 * r),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20 * r,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 4 * r),
                                Image.memory(
                                    item.file,
                                    height: 48 * r,
                                    width: 48 * r,
                                    fit: .cover
                                ),
                              ],
                            ),
                            SizedBox(height: 8 * r),
                            Text("${info?.id} - ${info?.label}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14 * r,
                                  fontWeight: .w500
                              ),
                            ),
                            Text(
                                "${info?.url}",
                                maxLines: 2,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10 * r,
                                    fontWeight: .w500
                                )
                            )
                          ]
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CupertinoButton(
                            color: Colors.redAccent,
                            borderRadius: .circular(100),
                            padding: .zero,
                            onPressed: () {
                              widget.onRemoveItem(item.id);
                            },
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 10,
                              color: Colors.white,
                            )
                          ),
                        ),
                      )
                    ],
                  )
                );
              }
            );
          }
        )
      ),
    );
  }
}
