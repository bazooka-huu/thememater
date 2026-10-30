import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:theme_maker/models/icon_item.dart';
import 'package:theme_maker/models/resource_type.dart';
import 'package:uuid/uuid.dart';

import 'export_status.dart';

abstract class ExportItem {
  String id;
  ResourceType type;
  ExportStatus status;

  ExportItem({
    required this.type,
    this.status = .waitingToProcess,
  }) : id = Uuid().v1();

  String getBasename(String themeId);
  String getMimeType(String themeId) {
    return lookupMimeType(getBasename(themeId)) ?? 'application/octet-stream';
  }

}


class FileExportItem extends ExportItem {
  Uint8List data;

  FileExportItem({
    required super.type,
    required this.data
  });

  @override
  String getBasename(String themeId) {
    if (type == .previewIphone) {
      return "theme$themeId.webp";
    } if (type == .previewIpad) {
      return "themeipad$themeId.webp";
    } else if (type == .bgIphone) {
      return "bgtheme$themeId.jpg";
    } else if(type == .bgIpad) {
      return "bgthemeipad$themeId.jpg";
    } else if (type == .lsIphone) {
      return "lstheme$themeId.jpg";
    } else if(type == .lsIpad) {
      return "lsthemeipad$themeId.jpg";
    } else if (type == .mediumWidget1) {
      return "widgets/widget_1.png";
    } else if (type == .largeWidget1) {
      return "widgets/widget_1_1.png";
    } else if (type == .mediumWidget2) {
      return "widgets/widget_2.png";
    } else if (type == .largeWidget2) {
      return "widgets/widget_2_1.png";
    } else if (type == .mediumWidget3) {
      return "widgets/widget_3.png";
    } else if (type == .largeWidget3) {
      return "widgets/widget_3_1.png";
    } else {
      return "";
    }
  }
}

class WidgetPreviewExportItem extends ExportItem {
  int index;
  Uint8List data;

  WidgetPreviewExportItem({
    required super.type,
    required this.index,
    required this.data
  });

  @override
  String getBasename(String themeId) {
    if (type == .previewWidget) {
      return "widgets/widget_${index}_20x20.png";
    } else {
      return "";
    }
  }
}


class IconExportItem extends ExportItem {
  IconItem item;

  IconExportItem({
    required super.type,
    required this.item
  });

  @override
  String getBasename(String themeId) {
    if (type == .icon) {
      return "icons/${item.id}.png";
    } else {
      return "";
    }
  }
}

class IconPreviewExportItem extends ExportItem {
  List<Uint8List> files;

  IconPreviewExportItem({
    required super.type,
    required this.files
  });

  @override
  String getBasename(String themeId) {
    if (type == .iconsPreview) {
      return "banner_${themeId}_1.png";
    } else {
      return "";
    }
  }
}

class IconProfileExportItem extends ExportItem {
  List<IconItem> files;
  IconProfileExportItem({
    required super.type,
    required this.files
  });

  @override
  String getBasename(String themeId) {
    if (type == .iconLog) {
      return "${themeId}_icons";
    } else if (type == .profile) {
      return "$themeId.mobileconfig";
    } else {
      return "";
    }
  }
}