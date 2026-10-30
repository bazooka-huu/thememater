import 'dart:typed_data';
import 'package:theme_maker/models/export_status.dart';

class TinyTask {
  TinyTask({
    required this.id,
    required this.input,
    required this.mimeType,
    this.output,
    this.status = ExportStatus.waitingToProcess,
  });

  final String id;
  final Uint8List input;
  final String mimeType;
  Uint8List? output;
  ExportStatus status;
}