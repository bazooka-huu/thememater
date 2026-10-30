part of 'main_cubit.dart';

class MainState extends Equatable {
  Uint8List? previewIpadFile;
  Uint8List? previewIphoneFile;
  Uint8List? lsIpadFile;
  Uint8List? lsIphoneFile;
  Uint8List? bgIpadFile;
  Uint8List? bgIphoneFile;
  List<ResourceType> selectedItems = [];
  List<IconItem> iconItems = [];
  List<IconItem?> iconPreviewItems = List<IconItem?>.filled(12, null);
  Uint8List? mediumWidget1File;
  Uint8List? largeWidget1File;
  Uint8List? mediumWidget2File;
  Uint8List? largeWidget2File;
  Uint8List? mediumWidget3File;
  Uint8List? largeWidget3File;

  MainState({
    this.previewIpadFile,
    this.previewIphoneFile,
    this.bgIpadFile,
    this.bgIphoneFile,
    this.lsIpadFile,
    this.lsIphoneFile,
    this.iconItems = const [],
    List<IconItem?>? iconPreviewItems,
    this.selectedItems = const [],
    this.mediumWidget1File,
    this.largeWidget1File,
    this.mediumWidget2File,
    this.largeWidget2File,
    this.mediumWidget3File,
    this.largeWidget3File
  }) : this.iconPreviewItems = iconPreviewItems ?? List<IconItem?>.filled(12, null);

  static const _unset = Object();
  MainState copyWith({
    Object? previewIpadFile = _unset,
    Object? previewIphoneFile = _unset,
    Object? bgIphoneFile = _unset,
    Object? bgIpadFile = _unset,
    Object? lsIphoneFile = _unset,
    Object? lsIpadFile = _unset,
    List<ResourceType>? selectedItems,
    List<IconItem>? iconItems,
    List<IconItem?>? iconPreviewItems,
    Object? mediumWidget1File = _unset,
    Object? largeWidget1File = _unset,
    Object? mediumWidget2File = _unset,
    Object? largeWidget2File = _unset,
    Object? mediumWidget3File = _unset,
    Object? largeWidget3File = _unset
  }) {
    return MainState(
      previewIpadFile: identical(previewIpadFile, _unset)
        ? this.previewIpadFile
        : previewIpadFile as Uint8List?,
      previewIphoneFile: identical(previewIphoneFile, _unset)
        ? this.previewIphoneFile
        : previewIphoneFile as Uint8List?,
      bgIphoneFile: identical(bgIphoneFile, _unset)
        ? this.bgIphoneFile
        : bgIphoneFile as Uint8List?,
      bgIpadFile: identical(bgIpadFile, _unset)
        ? this.bgIpadFile
        : bgIpadFile as Uint8List?,
      lsIphoneFile: identical(lsIphoneFile, _unset)
          ? this.lsIphoneFile
          : lsIphoneFile as Uint8List?,
      lsIpadFile: identical(lsIpadFile, _unset)
          ? this.lsIpadFile
          : lsIpadFile as Uint8List?,
      selectedItems: selectedItems ?? this.selectedItems,
      iconItems: iconItems ?? this.iconItems,
      iconPreviewItems: iconPreviewItems ?? this.iconPreviewItems,
      mediumWidget1File: identical(mediumWidget1File, _unset)
        ? this.mediumWidget1File
        : mediumWidget1File as Uint8List?,
      largeWidget1File: identical(largeWidget1File, _unset)
        ? this.largeWidget1File
        : largeWidget1File as Uint8List?,
      mediumWidget2File: identical(mediumWidget2File, _unset)
        ? this.mediumWidget2File
        : mediumWidget2File as Uint8List?,
      largeWidget2File: identical(largeWidget2File, _unset)
        ? this.largeWidget2File
        : largeWidget2File as Uint8List?,
      mediumWidget3File: identical(mediumWidget3File, _unset)
        ? this.mediumWidget3File
        : mediumWidget3File as Uint8List?,
      largeWidget3File: identical(largeWidget3File, _unset)
        ? this.largeWidget3File
        : largeWidget3File as Uint8List?,
    );
  }

  List<ExportItem> get exportItems {
    List<ExportItem> items = [];
    for (ResourceType item in selectedItems) {
      if (item == .previewIphone && previewIphoneFile != null)  {
        items.add(FileExportItem(type: .previewIphone, data: previewIphoneFile!));
      }
      if (item == .previewIpad && previewIpadFile != null)  {
        items.add(FileExportItem(type: .previewIpad, data: previewIpadFile!));
      }
      if (item == .bgIphone && bgIphoneFile != null)  {
        items.add(FileExportItem(type: .bgIphone, data: bgIphoneFile!));
      }
      if (item == .bgIpad && bgIpadFile != null)  {
        items.add(FileExportItem(type: .bgIpad, data: bgIpadFile!));
      }

      if (item == .lsIphone && lsIphoneFile != null)  {
        items.add(FileExportItem(type: .lsIphone, data: lsIphoneFile!));
      }
      if (item == .lsIpad && lsIpadFile != null)  {
        items.add(FileExportItem(type: .lsIpad, data: lsIpadFile!));
      }
      if (item == .mediumWidget1 && mediumWidget1File != null)  {
        items.add(FileExportItem(type: .mediumWidget1, data: mediumWidget1File!));
      }
      if (item == .largeWidget1 && largeWidget1File != null)  {
        items.add(FileExportItem(type: .largeWidget1, data: largeWidget1File!));
        items.add(WidgetPreviewExportItem(type: .previewWidget, data: largeWidget1File!, index: 1));
      }
      if (item == .mediumWidget2 && mediumWidget2File != null)  {
        items.add(FileExportItem(type: .mediumWidget2, data: mediumWidget2File!));
      }
      if (item == .largeWidget2 && largeWidget2File != null)  {
        items.add(FileExportItem(type: .largeWidget2, data: largeWidget2File!));
        items.add(WidgetPreviewExportItem(type: .previewWidget, data: largeWidget2File!, index: 2));
      }
      if (item == .mediumWidget3 && mediumWidget3File != null)  {
        items.add(FileExportItem(type: .mediumWidget3, data: mediumWidget3File!));
      }
      if (item == .largeWidget3 && largeWidget3File != null)  {
        items.add(FileExportItem(type: .largeWidget3, data: largeWidget3File!));
        items.add(WidgetPreviewExportItem(type: .previewWidget, data: largeWidget3File!, index: 3));
      }
      if (item == .iconsPreview && iconPreviewItems.every((e) => e != null)) {
        items.add(IconPreviewExportItem(type: .iconsPreview, files: iconPreviewItems.map((e) => e!.file).toList()));
      }
      if (item == .icons) {
        for (IconItem icon in iconItems) {
          items.add(IconExportItem(
            type: .icon, item: icon
          ));
        }
      }
      if (item == .profile) {
        if (iconItems.isNotEmpty) {
          items.add(IconProfileExportItem(type: .profile, files: iconItems));
          items.add(IconProfileExportItem(type: .iconLog, files: iconItems));
        }
      }
    }
    return items;
  }

  @override
  List<Object?> get props => [
    previewIpadFile,
    previewIphoneFile,
    selectedItems,
    bgIphoneFile,
    bgIpadFile,
    lsIphoneFile,
    lsIpadFile,
    iconItems,
    iconPreviewItems,
    mediumWidget1File,
    largeWidget1File,
    mediumWidget2File,
    largeWidget2File,
    mediumWidget3File,
    largeWidget3File
  ];
}
