import 'dart:ui';

import 'package:flutter/material.dart';

enum ExportStatus {
  waitingToProcess, processing, finish, fail;

  String get displayName  {
    switch (this) {
      case .waitingToProcess: return "Waiting to process";
      case .processing: return "Processing";
      case .finish: return "Finish";
      case .fail: return "Fail";
  }
  }
  Color get color  {
    switch (this) {
      case .waitingToProcess: return Colors.lightBlue;
      case .processing: return Colors.yellow;
      case .finish: return Colors.green;
      case .fail: return Colors.red;
    }
  }
}