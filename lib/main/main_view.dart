import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_maker/cubit/main_cubit.dart';
import 'package:theme_maker/export/export_view.dart';
import 'package:theme_maker/main/shared/icons_grid.dart';
import 'package:theme_maker/main/shared/icons_placeholder.dart';
import 'package:theme_maker/main/shared/image_item.dart';
import 'package:theme_maker/main/shared/image_placeholder.dart';
import 'package:theme_maker/models/resource_type.dart';
import '../models/icon_item.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  final TextEditingController _themeId = TextEditingController();
  final TextEditingController _themeName = TextEditingController();
  String? _lastPickedDirectory;
  late MainCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _cubit = context.read<MainCubit>();
    _themeId.text = "1090";
    _themeName.text = "Capybara";
    loadLastPickedDirectory();
    super.initState();
  }

  Future<PlatformFile?> _pickImage() async {
    final file = await FilePicker.pickFile(
      initialDirectory: _lastPickedDirectory,
      windowsOptions: const WindowsOptions(acceptLabel: 'Choose'),
      linuxOptions: const LinuxOptions(acceptLabel: 'Choose'),
      darwinOptions: const DarwinOptions(acceptLabel: 'Choose'),
    );
    if (file != null && file.path != null) {
      final parentDir = File(file.path!).parent.path;
      _lastPickedDirectory = parentDir;
      cacheLastPickedDirectory(parentDir);
    }
    return file;
  }

  Future<List<PlatformFile>> _pickImages() async {
    final files = await FilePicker.pickFiles(
      initialDirectory: _lastPickedDirectory,
      windowsOptions: const WindowsOptions(acceptLabel: 'Choose'),
      linuxOptions: const LinuxOptions(acceptLabel: 'Choose'),
      darwinOptions: const DarwinOptions(acceptLabel: 'Choose'),
    );
    if (files .isNotEmpty && files.first.path != null) {
      final parentDir = File(files.first.path!).parent.path;
      _lastPickedDirectory = parentDir;
      cacheLastPickedDirectory(parentDir);
    }
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: .symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _themeId,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: .w500,
                          fontSize: 16
                        ),
                        cursorColor: Colors.black,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "1089, 1090, ....",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: .w400,
                            fontSize: 16
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.5
                            )
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _themeName,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: .w500,
                          fontSize: 16
                        ),
                        cursorColor: Colors.black,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Capybara, Bunny, Cat,....",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: .w400,
                            fontSize: 16
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: .new(
                              color: Colors.grey,
                              width: 1.5
                            )
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: .circular(12),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.5
                            )
                          ),
                        )
                      )
                    ),
                    SizedBox(width: 32),
                    CupertinoButton(
                      padding: .all(8),
                      color: Colors.lightBlue,
                      child: Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showModalBottomSheet<void>(
                            context: context,
                            enableDrag: false,
                            isDismissible: false,
                            backgroundColor: Colors.white,
                            builder: (BuildContext context) {
                              return ExportView(
                                themeId: _themeId.text,
                                themeName: _themeName.text,
                                exportItems: _cubit.state.exportItems,
                              );
                            },
                          );
                        }
                      }
                    ),
                  ]
                )
              ),
              SizedBox(height: 16),
              _buildPreview(),
              SizedBox(height: 16),
              _buildFullBackground(),
              SizedBox(height: 16),
              _buildIcons(),
              SizedBox(height: 16),
              _buildWidget(),
              SizedBox(height: 32)
            ],
          ),
        ),
      )
    );
  }

  Widget _buildFullBackground() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 920) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  padding: .all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 1,
                        blurStyle: .outer
                      )
                    ]
                  ),
                  child: _buildBackground(),
                )
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: .all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 1,
                        blurStyle: .outer
                      )
                    ]
                  ),
                  child: _buildLockScreenBackground()
                ),
              )
            ]
          );
        }
        return Column(
          children: [
            _buildBackground(),
            SizedBox(height: 16),
            _buildLockScreenBackground()
          ],
        );
      }
    );
  }

  Widget _buildBackground() {
    return Column(
      children: [
        Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BlocSelector<MainCubit, MainState, (Uint8List?, Uint8List?, List<ResourceType>)>(
                  selector: (state) => (state.bgIphoneFile, state.bgIpadFile, state.selectedItems),
                  builder: (context, state) {
                    final items = state.$3;
                    final bgIphoneFile = state.$1;
                    final bgIpadFile = state.$2;
                    return CupertinoCheckbox(
                      value: items.contains(ResourceType.bgIphone) &&
                          items.contains(ResourceType.bgIpad),
                      onChanged: bgIphoneFile == null ||
                          bgIpadFile == null ? null : (value) {
                        if (value ?? false) {
                          _cubit.selectItems([ResourceType.bgIphone, ResourceType.bgIpad]);
                        } else {
                          _cubit.deselectItems([ResourceType.bgIphone, ResourceType.bgIpad]);
                        }
                      }
                    );
                  }
                ),
                SizedBox(width: 8),
                Text(
                  "Background",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: .w600
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 350
              ),
              child: Row(
                children: [
                  BlocSelector<MainCubit, MainState, Uint8List?>(
                    selector: (state) => state.bgIphoneFile,
                    builder: (context, bgIphoneFile) {
                      final data = bgIphoneFile;
                      if (data != null) {
                        return BlocSelector<MainCubit, MainState, bool>(
                          selector: (state) => state.selectedItems.contains(ResourceType.bgIphone),
                          builder: (context, isSelect) {
                            return ImageItem(
                              data: data,
                              isSelect: isSelect,
                              aspectRatio: 9 / 21,
                              onDelete: () {
                                _cubit.setBgIphoneFile(null);
                                _cubit.deselectItems([ResourceType.bgIphone]);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                final data = await file?.readAsBytes();
                                if (data != null) {
                                  _cubit.setBgIphoneFile(data);
                                }
                              },
                              onSelect: (value) {
                                if (isSelect) {
                                  _cubit.deselectItems([ResourceType.bgIphone]);
                                } else {
                                  _cubit.selectItems([ResourceType.bgIphone]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setBgIphoneFile(newImage);
                              },
                            );
                          }
                        );
                      }
                      return ImagePlaceholder(
                        aspectRatio: 9/21,
                        sizeString: "1170×2532",
                        onTap: () async {
                          PlatformFile? file = await _pickImage();
                          final data = await file?.readAsBytes();
                          if (data != null) {
                            _cubit.setBgIphoneFile(data);
                          }
                        },
                        onDropFile: (newImage) {
                          _cubit.setBgIphoneFile(newImage);
                        },
                      );
                    }
                  ),
                  SizedBox(width: 12),
                  BlocSelector<MainCubit, MainState, Uint8List?>(
                    selector: (state) => state.bgIpadFile,
                    builder: (context, bgIpadFile) {
                      final data = bgIpadFile;
                      if (data != null) {
                        return BlocSelector<MainCubit, MainState, bool>(
                          selector: (state) => state.selectedItems.contains(ResourceType.bgIpad),
                          builder: (context, isSelect) {
                            return ImageItem(
                              data: data,
                              isSelect: isSelect,
                              aspectRatio: 3 / 4,
                              onDelete: () {
                                _cubit.setBgIpadFile(null);
                                _cubit.deselectItems([ResourceType.bgIpad]);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                final data = await file?.readAsBytes();
                                if (data != null) {
                                  _cubit.setBgIpadFile(data);
                                }
                              },
                              onSelect: (value) {
                                if (isSelect) {
                                  _cubit.deselectItems([ResourceType.bgIpad]);
                                } else {
                                  _cubit.selectItems([ResourceType.bgIpad]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setBgIpadFile(newImage);
                              },
                            );
                          }
                        );
                      }
                      return ImagePlaceholder(
                        aspectRatio: 3/4,
                        sizeString: "1536×2040",
                        onTap: () async {
                          PlatformFile? file = await _pickImage();
                          final data = await file?.readAsBytes();
                          if (data != null) {
                            _cubit.setBgIpadFile(data);
                          }
                        },
                        onDropFile: (newImage) {
                          _cubit.setBgIpadFile(newImage);
                        }
                      );
                    }
                  ),
                ]
              )
            )
          ]
        )
      ]
    );
  }

  Widget _buildLockScreenBackground() {
    return Column(
      children: [
        Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BlocSelector<MainCubit, MainState, (Uint8List?, Uint8List?, List<ResourceType>)>(
                  selector: (state) => (state.lsIphoneFile, state.lsIpadFile, state.selectedItems),
                  builder: (context, state) {
                    final items = state.$3;
                    final lsIphoneFile = state.$1;
                    final lsIpadFile = state.$2;
                    return CupertinoCheckbox(
                      value: items.contains(ResourceType.lsIphone) &&
                          items.contains(ResourceType.lsIpad),
                      onChanged: lsIphoneFile == null ||
                          lsIpadFile == null ? null : (value) {
                        if (value ?? false) {
                          _cubit.selectItems([ResourceType.lsIphone, ResourceType.lsIpad]);
                        } else {
                          _cubit.deselectItems([ResourceType.lsIphone, ResourceType.lsIpad]);
                        }
                      }
                    );
                  }
                ),
                SizedBox(width: 8),
                Text(
                  "Lock Screen",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: .w600
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 350
              ),
              child: Row(
                children: [
                  BlocSelector<MainCubit, MainState, Uint8List?>(
                    selector: (state) => state.lsIphoneFile,
                    builder: (context, lsIphoneFile) {
                      final data = lsIphoneFile;
                      if (data != null) {
                        return BlocSelector<MainCubit, MainState, bool>(
                          selector: (state) => state.selectedItems.contains(ResourceType.lsIphone),
                          builder: (context, isSelect) {
                            return ImageItem(
                              data: data,
                              isSelect: isSelect,
                              aspectRatio: 9 / 21,
                              onDelete: () {
                                _cubit.setLsIphoneFile(null);
                                _cubit.deselectItems([ResourceType.lsIphone]);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                final data = await file?.readAsBytes();
                                if (data != null) {
                                  _cubit.setLsIphoneFile(data);
                                }
                              },
                              onSelect: (value) {
                                if (isSelect) {
                                  _cubit.deselectItems([ResourceType.lsIphone]);
                                } else {
                                  _cubit.selectItems([ResourceType.lsIphone]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setLsIphoneFile(newImage);
                              },
                            );
                          }
                        );
                      }
                      return ImagePlaceholder(
                        aspectRatio: 9/21,
                        sizeString: "1170×2532",
                        onTap: () async {
                          PlatformFile? file = await _pickImage();
                          final data = await file?.readAsBytes();
                          if (data != null) {
                            _cubit.setLsIphoneFile(data);
                          }
                        },
                        onDropFile: (newImage) {
                          _cubit.setLsIphoneFile(newImage);
                        },
                      );
                    }
                  ),
                  SizedBox(width: 12),
                  BlocSelector<MainCubit, MainState, Uint8List?>(
                    selector: (state) => state.lsIpadFile,
                    builder: (context, lsIpadFile) {
                      final data = lsIpadFile;
                      if (data != null) {
                        return BlocSelector<MainCubit, MainState, bool>(
                          selector: (state) => state.selectedItems.contains(ResourceType.lsIpad),
                          builder: (context, isSelect) {
                            return ImageItem(
                              data: data,
                              isSelect: isSelect,
                              aspectRatio: 3 / 4,
                              onDelete: () {
                                _cubit.setLsIpadFile(null);
                                _cubit.deselectItems([ResourceType.lsIpad]);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                final data = await file?.readAsBytes();
                                if (data != null) {
                                  _cubit.setLsIpadFile(data);
                                }
                              },
                              onSelect: (value) {
                                if (isSelect) {
                                  _cubit.deselectItems([ResourceType.lsIpad]);
                                } else {
                                  _cubit.selectItems([ResourceType.lsIpad]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setLsIpadFile(newImage);
                              },
                            );
                          }
                        );
                      }
                      return ImagePlaceholder(
                        aspectRatio: 3/4,
                        sizeString: "1536×2040",
                        onTap: () async {
                          PlatformFile? file = await _pickImage();
                          final data = await file?.readAsBytes();
                          if (data != null) {
                            _cubit.setLsIpadFile(data);
                          }
                        },
                        onDropFile: (newImage) {
                          _cubit.setLsIpadFile(newImage);
                        }
                      );
                    }
                  ),
                ]
              )
            )
          ]
        )
      ]
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BlocSelector<MainCubit, MainState, (Uint8List?, Uint8List?, List<ResourceType>)>(
                  selector: (state) => (state.previewIphoneFile, state.previewIpadFile, state.selectedItems),
                  builder: (context, state) {
                    final items = state.$3;
                    final previewIphoneFile = state.$1;
                    final previewIpadFile = state.$2;
                    return CupertinoCheckbox(
                      value: items.contains(ResourceType.previewIpad) &&
                          items.contains(ResourceType.previewIphone),
                      onChanged: previewIphoneFile == null ||
                          previewIpadFile == null ? null : (value) {
                        if (value ?? false) {
                          _cubit.selectItems([ResourceType.previewIpad, ResourceType.previewIphone]);
                        } else {
                          _cubit.deselectItems([ResourceType.previewIpad, ResourceType.previewIphone]);
                        }
                      }
                    );
                  }
                ),
                SizedBox(width: 8),
                Text(
                  "Preview",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: .w600
                  ),
                ),
                Spacer()
              ],
            ),
            SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 350
              ),
              child: Row(
                children: [
                  BlocSelector<MainCubit, MainState, Uint8List?>(
                    selector: (state) => state.previewIphoneFile,
                    builder: (context, previewIphoneFile) {
                      final path = previewIphoneFile;
                      if (path != null) {
                        return BlocSelector<MainCubit, MainState, bool>(
                          selector: (state) => state.selectedItems.contains(ResourceType.previewIphone),
                          builder: (context, isSelect) {
                            return ImageItem(
                              data: path,
                              isSelect: isSelect,
                              aspectRatio: 9 / 21,
                              onDelete: () {
                                _cubit.setPreviewIphoneFile(null);
                                _cubit.deselectItems([ResourceType.previewIphone]);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                final data = await file?.readAsBytes();
                                if (data != null) {
                                  _cubit.setPreviewIphoneFile(data);
                                }
                              },
                              onSelect: (value) {
                                if (isSelect) {
                                  _cubit.deselectItems([ResourceType.previewIphone]);
                                } else {
                                  _cubit.selectItems([ResourceType.previewIphone]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setPreviewIphoneFile(newImage);
                              },
                            );
                          }
                        );
                      }
                      return ImagePlaceholder(
                        aspectRatio: 9/21,
                        sizeString: "1170×2532",
                        onTap: () async {
                          PlatformFile? file = await _pickImage();
                          final data = await file?.readAsBytes();
                          if (data != null) {
                            _cubit.setPreviewIphoneFile(data);
                          }
                        },
                        onDropFile: (newImage) {
                          _cubit.setPreviewIphoneFile(newImage);
                        }
                      );
                    }
                  ),
                  SizedBox(width: 12),
                  BlocSelector<MainCubit, MainState, Uint8List?>(
                    selector: (state) => state.previewIpadFile,
                    builder: (context, previewIpadFile) {
                      final path = previewIpadFile;
                      if (path != null) {
                        return BlocSelector<MainCubit, MainState, bool>(
                          selector: (state) => state.selectedItems.contains(ResourceType.previewIpad),
                          builder: (context, isSelect) {
                            return ImageItem(
                              data: path,
                              isSelect: isSelect,
                              aspectRatio: 3 / 4,
                              onDelete: () {
                                _cubit.setPreviewIpadFile(null);
                                _cubit.deselectItems([ResourceType.previewIpad]);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                final data = await file?.readAsBytes();
                                if (data != null) {
                                  _cubit.setPreviewIpadFile(data);
                                }
                              },
                              onSelect: (value) {
                                if (isSelect) {
                                  _cubit.deselectItems([ResourceType.previewIpad]);
                                } else {
                                  _cubit.selectItems([ResourceType.previewIpad]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setPreviewIpadFile(newImage);
                              },
                            );
                          }
                        );
                      }
                      return ImagePlaceholder(
                        aspectRatio: 3/4,
                        sizeString: "1536×2040",
                        onTap: () async {
                          PlatformFile? file = await _pickImage();
                          final data = await file?.readAsBytes();
                          if (data != null) {
                            _cubit.setPreviewIpadFile(data);
                          }
                        },
                        onDropFile: (newImage) {
                          _cubit.setPreviewIpadFile(newImage);
                        }
                      );
                    }
                  )
                ]
              )
            )
          ]
        )
      ]
    );
  }

  Widget _buildWidget() {
    return SizedBox(
      width: .infinity,
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Widgets",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: .w600
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            children: List.generate(3, (index) {
              ResourceType mediumResource = ResourceType.mediumWidget1;
              ResourceType largeResource = ResourceType.largeWidget1;
              if (index == 1) {
                mediumResource = ResourceType.mediumWidget2;
                largeResource = ResourceType.largeWidget2;
              }
              if (index == 2) {
                mediumResource = ResourceType.mediumWidget3;
                largeResource = ResourceType.largeWidget3;
              }
              return Container(
                width: 273,
                margin: .only(
                  right: index == 2 ? 0 : 32,
                  bottom: 16
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Row(
                      children: [
                        Text("Widget ${index + 1}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: .w500
                          )
                        ),
                        Spacer(),
                        BlocSelector<MainCubit, MainState, (Uint8List?, Uint8List?, List<ResourceType>)>(
                          selector: (state) => (_cubit.getMediumWidgetFile(index + 1), _cubit.getLargeWidgetFile(index + 1), state.selectedItems),
                          builder: (context, state) {
                            final items = state.$3;
                            final mediumWidget = state.$1;
                            final largeWidget = state.$2;
                            return CupertinoCheckbox(
                              value: items.contains(mediumResource) &&
                                  items.contains(largeResource),
                              onChanged: mediumWidget == null ||
                                  largeWidget == null ? null : (value) {
                                if (value ?? false) {
                                  _cubit.selectItems([mediumResource, largeResource]);
                                } else {
                                  _cubit.deselectItems([mediumResource, largeResource]);
                                }
                              }
                            );
                          }
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 127.5,
                      child: BlocSelector<MainCubit, MainState, (Uint8List?, List<ResourceType>)>(
                        selector: (state) => (_cubit.getMediumWidgetFile(index + 1), state.selectedItems),
                        builder: (context, state) {
                          final file = state.$1;
                          final isSelect = state.$2.contains(mediumResource);
                          if (file != null) {
                            return ImageItem(
                              data: file,
                              isSelect: isSelect,
                              aspectRatio: 273/127.5,
                              onDelete: () {
                                _cubit.setWidgetFile(null, resourceType: mediumResource);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                Uint8List? data = await file?.readAsBytes();
                                if (file != null) {
                                  _cubit.setWidgetFile(data, resourceType: mediumResource);
                                }
                              },
                              onSelect: (value) {
                                if (value) {
                                  _cubit.deselectItems([mediumResource]);
                                } else {
                                  _cubit.selectItems([mediumResource]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setWidgetFile(newImage, resourceType: mediumResource);
                              },
                            );
                          }
                          return ImagePlaceholder(
                            aspectRatio: 273/127.5,
                            sizeString: "960×450",
                            onTap: () async {
                              PlatformFile? file = await _pickImage();
                              Uint8List? data = await file?.readAsBytes();
                              if (file != null) {
                                _cubit.setWidgetFile(data, resourceType: mediumResource);
                              }
                            },
                            onDropFile: (newImage) {
                              _cubit.setWidgetFile(newImage, resourceType: mediumResource);
                            }
                          );
                        }
                      ),
                    ),
                    SizedBox(height: 12),

                    SizedBox(
                      height: 273,
                      child: BlocSelector<MainCubit, MainState, (Uint8List?, List<ResourceType>)>(
                        selector: (state) => (_cubit.getLargeWidgetFile(index + 1), state.selectedItems),
                        builder: (context, state) {
                          final Uint8List? file = state.$1;
                          final isSelect = state.$2.contains(largeResource);
                          if (file != null) {
                            return ImageItem(
                              data: file,
                              isSelect: isSelect,
                              aspectRatio: 1.0,
                              onDelete: () {
                                _cubit.setWidgetFile(null, resourceType: largeResource);
                              },
                              onChange: () async {
                                PlatformFile? file = await _pickImage();
                                Uint8List? data = await file?.readAsBytes();
                                if (file != null) {
                                  _cubit.setWidgetFile(data, resourceType: largeResource);
                                }
                              },
                              onSelect: (value) {
                                if (value) {
                                  _cubit.deselectItems([largeResource]);
                                } else {
                                  _cubit.selectItems([largeResource]);
                                }
                              },
                              onDropFile: (newImage) {
                                _cubit.setWidgetFile(newImage, resourceType: largeResource);
                              },
                            );
                          }
                          return ImagePlaceholder(
                            aspectRatio: 1.0,
                            sizeString: "1000×1000",
                            onTap: () async {
                              PlatformFile? file = await _pickImage();
                              Uint8List? data = await file?.readAsBytes();
                              if (file != null) {
                                _cubit.setWidgetFile(data, resourceType: largeResource);
                              }
                            },
                            onDropFile: (newImage) {
                              _cubit.setWidgetFile(newImage, resourceType: largeResource);
                            }
                          );
                        }
                      )
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      )
    );
  }

  Widget _buildIcons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 920) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: .all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 1,
                        blurStyle: .outer
                      )
                    ]
                  ),
                  child: _buildIconsGrid(),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 350,
                child: Container(
                  padding: .all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 1,
                        blurStyle: .outer
                      )
                    ]
                  ),
                  child: _buildIconPreview(
                    crossAxisCount: 3
                  ),
                )
              )
            ],
          );
        }
        return Column(
          children: [
            _buildIconsGrid(),
            SizedBox(height: 16),
            _buildIconPreview()
          ],
        );
      }
    );
  }

  Widget _buildIconsGrid() {
    return Column(
      mainAxisSize: .min,
      mainAxisAlignment: .start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BlocSelector<MainCubit, MainState, (List<IconItem>, List<ResourceType>)>(
              selector: (state) => (state.iconItems, state.selectedItems),
              builder: (context, state) {
                final items = state.$2;
                final iconItems = state.$1;
                return CupertinoCheckbox(
                  value: items.contains(ResourceType.icons),
                  onChanged: iconItems.isEmpty ? null : (value) {
                    if (value ?? false) {
                      _cubit.selectItems([ResourceType.icons]);
                    } else {
                      _cubit.deselectItems([ResourceType.icons]);
                    }
                  }
                );
              }
            ),
            SizedBox(width: 8),
            Text(
              "Icons",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: .w600
              ),
            ),
            SizedBox(width: 16),
            BlocSelector<MainCubit, MainState, (List<IconItem>, List<ResourceType>)>(
              selector: (state) => (state.iconItems, state.selectedItems),
              builder: (context, state) {
                final items = state.$2;
                final iconItems = state.$1;
                return CupertinoCheckbox(
                  value: items.contains(ResourceType.profile),
                  onChanged: iconItems.isEmpty ? null : (value) {
                    if (value ?? false) {
                      _cubit.selectItems([ResourceType.profile]);
                    } else {
                      _cubit.deselectItems([ResourceType.profile]);
                    }
                  }
                );
              }
            ),
            SizedBox(width: 8),
            Text(
              "Profile",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: .w600
              ),
            ),
            Spacer(),
            BlocSelector<MainCubit, MainState, bool>(
              selector: (state) => state.iconItems.isEmpty,
              builder: (context, hide) {
                if (hide) {
                  return SizedBox.shrink();
                }
                return TextButton(
                  child: Text(
                    "Clear",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: .w500,
                      fontSize: 16
                    )
                  ),
                  onPressed: () {
                    _cubit.clearIconItems();
                  }
                );
              }
            ),
            SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.lightBlue,
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.lightBlue,
                  width: 1.5,
                ),
              ),
              onPressed: () async {
                List<PlatformFile> files = await _pickImages();
                List<IconItem> iconItems = [];
                for (PlatformFile item in files) {
                  final id = int.tryParse(path.basenameWithoutExtension(item.name)) ?? -1;
                  final image = await item.xFile.readAsBytes();
                  iconItems.add(IconItem(
                    id: id,
                    file: image
                  ));
                }

                iconItems.removeWhere((e) => e.id < 0);
                _cubit.addNewIcons(iconItems);
              },
              child: Text("Add icons",
                style: TextStyle(
                  fontWeight: .w500,
                  fontSize: 16
                )
              )
            )
          ],
        ),
        SizedBox(height: 8),
        BlocSelector<MainCubit, MainState, List<IconItem>>(
          selector: (state) => state.iconItems,
          builder: (context, items) {
            if (items.isEmpty) {
              return IconsPlaceholder(
                onDropFiles: (files) {
                  _cubit.addNewIcons(files);
                }
              );
            }
            return IconsGrid(
              items: items,
              onDropFiles: (files) {
                _cubit.addNewIcons(files);
              },
              onRemoveItem:(id) {
                _cubit.removeIcon(id);
              },
            );
          }
        )
      ]
    );
  }

  Widget _buildIconPreview({
    int crossAxisCount = 1
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Column(
              mainAxisSize: .min,
              mainAxisAlignment: .start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BlocSelector<MainCubit, MainState, (bool, bool)>(
                      selector: (state) => (state.iconPreviewItems.every((e) => e != null), state.iconItems.isEmpty),
                      builder: (context, state) {
                        final bool active = state.$1;
                        final bool lock = state.$2;
                        return CupertinoCheckbox(
                          value: active,
                          onChanged: lock ? null : (value) {
                            if (value ?? true) {
                              _cubit.randomIconPreview();
                            } else {
                              _cubit.clearIconsPreview();
                            }
                          }
                        );
                      }
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Icons Preview",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: .w600
                      ),
                    ),
                    Spacer(),
                    BlocSelector<MainCubit, MainState, bool>(
                      selector: (state) => state.iconItems.isEmpty,
                      builder: (context, hide) {
                        if (hide) {
                          return SizedBox.shrink();
                        }
                        return TextButton(
                          child: Text(
                            "Random",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: .w500,
                              fontSize: 16
                            )
                          ),
                          onPressed: () {
                            _cubit.randomIconPreview();
                          }
                        );
                      }
                    ),
                    BlocSelector<MainCubit, MainState, bool>(
                      selector: (state) => state.iconItems.isEmpty || state.iconPreviewItems.every((e) => e == null),
                      builder: (context, hide) {
                        if (hide) {
                          return SizedBox.shrink();
                        }
                        return TextButton(
                          onPressed: () async {
                            _cubit.clearIconsPreview();
                          },
                          child: Text("Clear",
                            style: TextStyle(
                              fontWeight: .w500,
                              fontSize: 16,
                              color: Colors.red
                            )
                          )
                        );
                      }
                    )
                  ],
                ),
                SizedBox(height: 12),
                Center(
                  child: BlocSelector<MainCubit, MainState, List<IconItem?>>(
                    selector: (state) => state.iconPreviewItems,
                    builder: (context, items) {
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
                            return _buildIconPreviewCell(
                              index,
                              items,
                            );
                          }),
                        ),
                      );
                    }
                  ),
                ),
                SizedBox(height: 16),
                BlocSelector<MainCubit, MainState, List<IconItem>>(
                  selector: (state) => state.iconItems,
                  builder: (context, items) {
                    return SizedBox(
                      height: 48 * crossAxisCount + 8 * (crossAxisCount - 1),
                      child: GridView.builder(
                        scrollDirection: .horizontal,
                        padding: .zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Draggable<IconItem>(
                            data: item,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    item.file,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // Keep the original icon in the horizontal list.
                            childWhenDragging: Opacity(
                              opacity: 0.35,
                              child: _buildDraggableIcon(item),
                            ),

                            // The icon displayed in the horizontal list.
                            child: _buildDraggableIcon(item),
                          );
                        }
                      )
                    );
                  }
                )
              ]
            )
          ]
        );
      }
    );
  }

  Widget _buildDraggableIcon(IconItem item) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          item.file,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildIconPreviewCell(int index, List<IconItem?> items) {
    final item = index < items.length ? items[index] : null;

    return DragTarget<IconItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final updated = List<IconItem?>.from(_cubit.state.iconPreviewItems);

        // Ensure the grid always has 12 slots.
        while (updated.length < 12) {
          updated.add(null);
        }

        updated[index] = details.data;
        _cubit.updateIconPreview(updated);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isHovering
              ? Colors.lightBlue.withValues(alpha: 0.25)
              : Colors.grey,
            borderRadius: BorderRadius.circular(8),
            border: isHovering
              ? Border.all(color: Colors.lightBlue, width: 1.5)
              : null,
          ),
          child: item == null
            ? const SizedBox.expand()
            : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                item.file,
                fit: BoxFit.cover,
              ),
            ),
        );
      },
    );
  }

  Future<void> loadLastPickedDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPickedDirectory = prefs.getString('lastPickedDirectory');
    if(Directory(lastPickedDirectory ?? "").existsSync()) {
      _lastPickedDirectory = lastPickedDirectory;
    } else {
      await prefs.remove('lastPickedDirectory');
    }
  }

  Future<void> cacheLastPickedDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastPickedDirectory', path);
  }
}




