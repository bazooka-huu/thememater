import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_maker/models/export_item.dart';
import 'package:theme_maker/models/export_status.dart';
import 'package:theme_maker/models/icon_info.dart';
import 'package:theme_maker/models/output_item.dart';
import 'package:theme_maker/utils/tiny/models/tiny_task.dart';
import 'package:theme_maker/utils/tiny/tiny_png_compressor.dart';
import 'package:uuid/uuid.dart';
import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:collection/collection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';


class ExportView extends StatefulWidget {
  final String themeId;
  final String themeName;
  final List<ExportItem> exportItems;
  const ExportView({super.key, required this.themeId, required this.themeName, required this.exportItems});

  @override
  State<ExportView> createState() => _ExportViewState();
}

class _ExportViewState extends State<ExportView> {
  final ValueNotifier<List<ExportItem>> _tasks = .new([]);
  final ValueNotifier<List<OutputItem>> _outputs = .new([]);
  final ValueNotifier<bool> _isDownloading = .new(false);
  late final TinyPngCompressor compressor;
  final ScreenshotController _screenshotController = ScreenshotController();
  final ValueNotifier<ExportStatus> _status = .new(.waitingToProcess);
  final ValueNotifier<String?> _saveFolderPath = .new(null);
  @override
  void initState() {
    _tasks.value = widget.exportItems;
    compressor = TinyPngCompressor(
      apiKey: 'YOUR_API_KEY',
      maxWorkers: 2,
    );
    loadLastPickedDirectory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: .all(8),
            width: .infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1,
                  blurStyle: .inner
                )
              ]
            ),
            child: Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: _isDownloading,
                  builder: (context, isDownloading, child) {
                    return ValueListenableBuilder<ExportStatus>(
                      valueListenable: _status,
                      builder: (context, status, child) {
                        return TextButton(
                          onPressed: status == .processing || isDownloading ? null : () => Navigator.pop(context),
                          child: Text('Close',
                            style: TextStyle(
                              color: status == .processing || isDownloading ? Colors.grey : Colors.red,
                              fontWeight: .w400,
                              fontSize: 16
                            )
                          ),
                        );
                      }
                    );
                  }
                ),
                SizedBox(width: 16),
                Spacer(),
                SizedBox(width: 16),
                ValueListenableBuilder(
                  valueListenable: _isDownloading,
                  builder: (context, isDownloading, child) {
                    return ValueListenableBuilder<ExportStatus>(
                      valueListenable: _status,
                      builder: (context, status, child) {
                        return CupertinoButton(
                          color: Colors.lightBlue,
                          padding: .symmetric(horizontal: 16, vertical: 8),
                          onPressed: status == .processing || isDownloading ? null : () {
                            _startExport();
                          },
                          child: status == .processing ? CircularProgressIndicator.adaptive() : Text("Export all",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: .w400,
                              fontSize: 16
                            ),
                          )
                        );
                      }
                    );
                  }
                ),
                SizedBox(width: 12),
                ValueListenableBuilder(
                  valueListenable: _isDownloading,
                    builder: (context, isDownloading, child) {
                      return ValueListenableBuilder(
                      valueListenable: _outputs,
                      builder: (context, outputs, child) {
                        return ValueListenableBuilder<ExportStatus>(
                          valueListenable: _status,
                          builder: (context, status, child) {
                            if (status == .finish && outputs.isNotEmpty) {
                              return CupertinoButton(
                                color: Colors.lightBlue,
                                padding: .symmetric(horizontal: 16, vertical: 8),
                                onPressed: isDownloading ? null : () {
                                  _downloadAll();
                                },
                                child: isDownloading ? CircularProgressIndicator.adaptive() : Text("Download all",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: .w400,
                                    fontSize: 16
                                  ),
                                )
                              );
                            }
                            return SizedBox.shrink();
                          }
                        );
                      }
                    );
                  }
                )
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _outputs,
              builder: (context, outputs, child) {
                return  ValueListenableBuilder(
                  valueListenable: _tasks,
                  builder: (context, tasks, child) {
                    return ListView.separated(
                      shrinkWrap: true,
                      padding: .only(bottom: 32),
                      itemBuilder: (context, index) {
                        ExportItem item = tasks[index];
                        Uint8List? output = outputs.firstWhereOrNull((e) => e.id == item.id)?.data;
                        return Row(
                          children: [
                            Text("${widget.themeId}/${item.getBasename(widget.themeId)}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: .w500
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: .all(4),
                              decoration: BoxDecoration(
                                color: item.status.color,
                                borderRadius: .circular(100)
                              ),
                              child: Text(item.status.displayName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: .w500
                                ),
                              ),
                            ),
                            if (output != null)
                              IconButton(
                                padding: .zero,
                                onPressed: () async {
                                  final uri = await FilePicker.saveFile(
                                    fileName: item.getBasename(widget.themeId),
                                    mimeType: item.getMimeType(widget.themeId),
                                    bytes: output
                                  );
                                  if (uri != null) {
                                    final parentDir = File(uri.path).parent.path;
                                    _saveFolderPath.value = parentDir;
                                    _cacheLastPickedDirectory(parentDir);
                                  }

                                },
                                icon: Icon(
                                  Icons.download_for_offline,
                                  size: 24,
                                  color: Colors.lightBlue,
                                )
                              )
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 4);
                      },
                      itemCount: tasks.length,
                    );
                  }
                );
              }
            )
          ),
          ValueListenableBuilder<int>(
            valueListenable: compressor.retryCountdown,
            builder: (context, seconds, child) {
              if (seconds == 0) {
                return const SizedBox.shrink();
              }
              return Text(
                'Retrying in ${seconds}s...',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _startExport() async {
    _status.value = .processing;
    _outputs.value = [];
    final themeId = widget.themeId;
    //handle icons
    List<IconExportItem> iconExportItems = _tasks.value.whereType<IconExportItem>()
        .toList();
    List<TinyTask> tasks = iconExportItems.map(
      (e) {
        return TinyTask(id: e.id, input: e.item.file, mimeType: e.getMimeType(themeId));
      }
    ).toList();
    await compressor.compressTasks(
      tasks,
      onChanged: (task) {
        final output = task.output;
        if(output != null) {
          _addOutput(task.id, output);
        }
        _changeItemStatus(task.id, task.status);
      },
    );
    tasks.clear();
    List<IconPreviewExportItem> iconPreviewExportItems = _tasks.value.whereType<IconPreviewExportItem>()
        .toList();
    if (iconExportItems.isNotEmpty) {
      for (IconPreviewExportItem item in iconPreviewExportItems) {
        if (mounted) {
          final Uint8List imageBytes = await _screenshotController
              .captureFromWidget(
            iconPreview(item.files),
            pixelRatio: 3.0,
            delay: const Duration(milliseconds: 1),
            context: context,
          );
          tasks.add(TinyTask(id: item.id, input: imageBytes, mimeType: item.getMimeType(themeId)));
        } else {
          _changeItemStatus(item.id, .fail);
        }
      }
    }

    List<WidgetPreviewExportItem> previewWidgetExportItems = _tasks.value.whereType<WidgetPreviewExportItem>()
        .toList();
    for(WidgetPreviewExportItem item in previewWidgetExportItems) {
      final output = await _resizeImage(item.data);
      if (output != null) {
        tasks.add(TinyTask(id: item.id, input: output, mimeType: item.getMimeType(themeId)));
      } else {
        _changeItemStatus(item.id, .fail);
      }
    }

    List<FileExportItem> fileExportItems = _tasks.value.whereType<FileExportItem>()
        .toList();
    for (var e in fileExportItems) {
      tasks.add(TinyTask(id: e.id, input: e.data, mimeType: e.getMimeType(themeId)));
    }

    await Future.wait([
      compressor.compressTasks(
        tasks,
        onChanged: (task) {
          final output = task.output;
          if(output != null) {
            _addOutput(task.id, output);
          }
          _changeItemStatus(task.id, task.status);
        },
      ),
      _generateIconProfile(),
      _generateIconInfo(),
    ]);
    _status.value = .finish;
  }

  void _changeItemStatus(String id, ExportStatus status) {
    List<ExportItem> tasks = List.from(_tasks.value);
    int index = tasks.indexWhere((e) => e.id == id);
    if(index > -1) {
      tasks[index].status = status;
      _tasks.value = tasks;
    }
  }

  Future<void> _generateIconProfile() async {
    final themeName = widget.themeName;
    final uniqueId = const Uuid().v4().toUpperCase();
    List<IconProfileExportItem> fileExportItems = _tasks.value.whereType<IconProfileExportItem>()
        .toList();
    final fileProfileExportItem = fileExportItems.firstWhereOrNull((e) => e.type == .profile);
    if (fileProfileExportItem == null) {
      return;
    }
    _changeItemStatus(fileProfileExportItem.id, .processing);
    final String content = await rootBundle.loadString('assets/template.mobileconfig');

    final dynamic parsed = PropertyListSerialization.propertyListWithString(content);
    final Map<String, dynamic> newProfile = Map<String, dynamic>.from(parsed as Map);

    // 4. Update root fields
    newProfile['PayloadIdentifier'] = 'com.gearvn.thememate.$uniqueId';
    newProfile['PayloadDisplayName'] = 'ThemeMate - $themeName';
    newProfile['PayloadDescription'] = themeName;

    // 5. Build new PayloadContent
    final List originalContent = List.from(newProfile['PayloadContent'] ?? []);
    final List<Map<String, dynamic>> newPayloadContent = [];

    for (final entry in fileProfileExportItem.files) {
      final info = IconInfo.defaultIcons.firstWhereOrNull((e) => e.id == entry.id);
      final name = info?.label ?? "";
      final id = entry.id;

      final index = originalContent.indexWhere((item) => item['Label'] == name);
      if (index == -1) continue;

      final item = Map<String, dynamic>.from(originalContent[index]);
      item['Icon'] = base64Encode(entry.file);
      newPayloadContent.add(item);
    }

    newProfile['PayloadContent'] = newPayloadContent;

    final String outputData = PropertyListSerialization.stringWithPropertyList(
      newProfile,
    );
    _changeItemStatus(fileProfileExportItem.id, .finish);
    _addOutput(fileProfileExportItem.id, Uint8List.fromList(utf8.encode(outputData)));
  }

  Future<void> _generateIconInfo() async {
    List<IconProfileExportItem> fileExportItems = _tasks.value.whereType<IconProfileExportItem>()
        .toList();


    final iconInfoFileExportItem = fileExportItems.firstWhereOrNull((e) => e.type == .iconLog);
    if (iconInfoFileExportItem == null) {
      return;
    }
    final ids = iconInfoFileExportItem.files.map((e) => e.id).join(",");
    _changeItemStatus(iconInfoFileExportItem.id, .finish);
    _addOutput(iconInfoFileExportItem.id, Uint8List.fromList(utf8.encode(ids)));
  }

  Widget iconPreview(List<Uint8List> items) {
    return SizedBox(
      width: 186,
      height: 143,
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 6.92,
        mainAxisSpacing: 6.92,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.0,
        children: List.generate(12, (index) {
          final item = index < items.length ? items[index] : null;
          if (item == null) {
            return Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: .circular(8),
                color: Colors.grey
              ),
            );
          }
          return SizedBox(
            width: 35,
            height: 35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                item,
                fit: BoxFit.cover,
              ),
            )
          );
        }),
      ),
    );
  }

  Future<void> loadLastPickedDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPickedDirectory = prefs.getString('lastPickedSaveDirectory');
    if(Directory(lastPickedDirectory ?? "").existsSync()) {
      _saveFolderPath.value = lastPickedDirectory ?? "";
    } else {
      await prefs.remove('lastPickedSaveDirectory');
    }
  }

  Future<void> _cacheLastPickedDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPickedSaveDirectory', path);
  }

  Future<Uint8List?> _resizeImage(Uint8List input) async {

    final image = img.decodeImage(input);
    if (image == null) return null;

    final resized = img.copyResize(
      image,
      width: 80,
      height: 80,
    );
    return img.encodePng(resized);
  }

  void _addOutput(String id, Uint8List output) {
    List<OutputItem> outputs = List.from(_outputs.value);
    int index = outputs.indexWhere((e) => e.id == id);
    if (index > -1) {
      outputs[index] = OutputItem(id: id, data: output);
    } else {
      outputs.add(OutputItem(id: id, data: output));
    }
    _outputs.value = outputs;
  }

  void _downloadAll() async {
    _isDownloading.value = true;
    final dir = await getTemporaryDirectory();
    Directory themeDir = Directory(path.join(dir.path, widget.themeId));
    if(themeDir.existsSync()) {
      themeDir.delete(recursive: true);
    }
    themeDir.createSync(recursive: true);
    for (OutputItem item in _outputs.value) {
      final baseName = _tasks.value.firstWhereOrNull((e) => e.id == item.id)?.getBasename(widget.themeId);

      if(baseName != null) {
        final filePath = path.join(themeDir.path, baseName);
        Directory parentDir = Directory(path.dirname(filePath));
        if(!parentDir.existsSync()) {
          parentDir.createSync(recursive: true);
        }
        File(filePath).writeAsBytesSync(item.data);
      }
    }
    try {
      final zipFile = File(path.join(dir.path, "${widget.themeId}.zip"));
      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      await encoder.addDirectory(themeDir);
      encoder.close();
      final data = zipFile.readAsBytesSync();
      await FilePicker.saveFile(fileName: "${widget.themeId}.zip", bytes: data);
      debugPrint('Folder successfully zipped!');
      themeDir.delete(recursive: true);
      zipFile.delete(recursive: true);
      _isDownloading.value = false;
    } catch (e) {
      debugPrint('Error creating zip: $e');
      _isDownloading.value = false;
    }
  }

  @override
  void dispose() {
    compressor.retryCountdown.dispose();
    super.dispose();
  }
}
