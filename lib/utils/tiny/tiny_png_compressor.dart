
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:theme_maker/models/export_status.dart';
import 'package:theme_maker/utils/tiny/models/tiny_task.dart';


class TinyPngCompressor {
  TinyPngCompressor({
    required this.apiKey,
    this.maxWorkers = 2,
  });

  final String apiKey;
  final int maxWorkers;

  /// Remaining seconds before retry. 0 means no retry delay.
  final ValueNotifier<int> retryCountdown = ValueNotifier(0);

  bool _isRunning = false;

  Future<void> compressTasks(
      List<TinyTask> tasks, {
        void Function(TinyTask task)? onChanged,
      }) async {
    if (_isRunning || tasks.isEmpty) return;

    _isRunning = true;

    try {
      while (tasks.any((task) => task.status != ExportStatus.finish)) {
        final pendingTasks = tasks
            .where((task) => task.status != ExportStatus.finish)
            .toList();

        var nextIndex = 0;
        var failed = false;

        final workerCount = maxWorkers.clamp(
          1,
          pendingTasks.length,
        );

        Future<void> worker() async {
          while (true) {
            // Stop assigning new tasks immediately after a failure.
            if (failed || nextIndex >= pendingTasks.length) {
              return;
            }

            final task = pendingTasks[nextIndex++];

            task.status = ExportStatus.processing;
            onChanged?.call(task);

            final input = task.input;
            final mimeType = task.mimeType;
            final output =await _tiny(
              input,
              mimeType
            );

            if (output != null) {
              task.status = ExportStatus.finish;
              task.output = output;
            } else {
              failed = true;
              task.status = ExportStatus.waitingToProcess;
            }

            onChanged?.call(task);
          }
        }

        await Future.wait(
          List.generate(workerCount, (_) => worker()),
        );

        // Reset every unfinished task after a failed batch.
        // Successful tasks remain finished and won't be retried.
        if (failed) {
          for (final task in tasks) {
            if (task.status != ExportStatus.finish) {
              task.status = ExportStatus.waitingToProcess;
              onChanged?.call(task);
            }
          }

          debugPrint('Compression failed. Retrying in 60 seconds.');

          for (var seconds = 60; seconds > 0; seconds--) {
            retryCountdown.value = seconds;
            await Future.delayed(const Duration(seconds: 1));
          }

          retryCountdown.value = 0;
        }
      }

      debugPrint('All ${tasks.length} tasks completed.');
    } finally {
      retryCountdown.value = 0;
      _isRunning = false;
      // Optionally notify once more if you want a final “done” signal.
      // for (final task in tasks) onChanged?.call(task);
    }
  }

  static const List<String> userAgents = [
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.133 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:110.0) Gecko/20100101 Firefox/110.0",
    "Mozilla/5.0 (Linux; Android 13; OnePlus 9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.91 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:110.0) Gecko/20100101 Firefox/110.0",
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.5993.104 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Samsung Galaxy S10e) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:95.0) Gecko/20100101 Firefox/95.0",
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:95.0) Gecko/20100101 Firefox/95.0",
    "Mozilla/5.0 (Linux; Android 13; Xiaomi Mi 11) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0",
    "Mozilla/5.0 (Linux; Android 11; Samsung Galaxy Note 20) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.5359.124 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:112.0) Gecko/20100101 Firefox/112.0",
    "Mozilla/5.0 (Linux; Android 10; Xiaomi Redmi Note 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 6.3; rv:110.0) Gecko/20100101 Firefox/110.0",
    "Mozilla/5.0 (Linux; Android 9; Google Pixel 3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.134 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Samsung Galaxy A72) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.85 Mobile Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.121 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 7.0; Huawei P10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.99 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
  ];

  // ⚠️ These cookies expire quickly. You will need to refresh them periodically.
  static const String cookies =
      'CookieConsent={stamp:%27-1%27%2Cnecessary:true%2Cpreferences:true%2Cstatistics:true%2Cmarketing:true%2Cmethod:%27implied%27%2Cver:1%2Cutc:1778484056517%2Ciab2:%27%27%2Cregion:%27VN%27}; '
      '_ga=GA1.1.887620726.1778484057; '
      '_gcl_au=1.1.436125529.1778484057.1353404012.1778484069.1778484068; '
      'sess=eyJpZCI6IjI4OTIyMzA3LWFkZGYtNDg1MC04ZWExLWRjOTcyZDQ3ZTcxMCIsInRva2VuIjoiUFZYM3FxcGdjdlhTaEZtUTJLNDhNODdiU0JsRkg4czdqR2ttU2hHeFlwU1h2RDFqIiwibm93IjoyMDU4NCwidGllciI6ImZyZWUifQ==; '
      'sess.sig=fvzA0uXS0WO5Quyhn7gEHrlUyvY; '
      '_ga_LGBK7BMHET=GS2.1.s1778484056\$o1\$g1\$t1778484872\$j58\$l0\$h1295284556; '
      'ph_phc_3UyPpkWwO4ZgeESA6mHnwOV449bcj055fDVz21fQnNC_posthog=%7B%22%24device_id%22%3A%22019e15e9-0fbd-75f7-807f-2d067cbb5182%22%2C%22distinct_id%22%3A%22019e15e9-0fbd-75f7-807f-2d067cbb5182%22%2C%22%24sesid%22%3A%5B1778484875770%2C%22019e15e9-0fbd-75f7-807f-2d07575902dc%22%2C1778484055997%5D%2C%22%24initial_person_info%22%3A%7B%22r%22%3A%22https%3A%2F%2Fwww.google.com%2F%22%2C%22u%22%3A%22https%3A%2F%2Ftinypng.com%2F%22%7D%2C%22%24user_state%22%3A%22anonymous%22%7D';

  static String _randomUserAgent() {
    return userAgents[Random().nextInt(userAgents.length)];
  }

  /// Upload → Process → return download URL
  static Future<String?> _tinyImage(Uint8List input, String mimeType) async {
    try {
      final headers = {
        'User-Agent': _randomUserAgent(),
        'Content-Type': 'application/octet-stream',
        'Connection': 'keep-alive',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Cookie': cookies,
      };

      final response = await http.post(
        Uri.parse('https://tinypng.com/backend/opt/store'),
        headers: headers,
        body: input,
      );

      if (response.statusCode == 201) {
        print('File uploaded successfully');
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final key = data['key'] as String;
        final size = data['size'] as int;

        return await _processFile(key, size, mimeType);
      } else {
        print('Failed to upload file. Status: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (err) {
      return null;
    }
  }

// Keep your existing implementation:
  static Future<String?> _processFile(String key, int size, String mimeType) async {
    final headers = {
      'User-Agent': _randomUserAgent(),
      'Content-Type': 'application/json',
      'Connection': 'keep-alive',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
    };

    final payload = {
      'key': key,
      'originalType': mimeType,
      'originalSize': size,
    };

    final response = await http.post(
      Uri.parse('https://tinypng.com/backend/opt/process'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      debugPrint('File processed successfully');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['url'] as String?;
    } else {
      debugPrint('Failed to process file. Status: ${response.statusCode}');
      debugPrint(response.body);
      return null;
    }
  }

  static Future<Uint8List?> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      debugPrint('Failed to download image. Status: ${response.statusCode}');
      return null;
    }
  }

  /// Main entry point
  static Future<Uint8List?> _tiny(Uint8List input, String mimeType) async {
    final imageUrl = await _tinyImage(input, mimeType);
    if (imageUrl != null) {
      final output = await _downloadImage(imageUrl);
      return output;
    }
    return null;
  }
}
