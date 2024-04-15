import 'package:ffmpeg_flutter/domain/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@Injectable(as: AppLogger)
class AppLoggerImpl implements AppLogger {
  @override
  void native({required StackTrace? stackTrace, Object? error}) {
    if (kDebugMode) {
      Logger().e('Ошибка натива', stackTrace: stackTrace, error: error, time: DateTime.now());
    }
  }

  @override
  void info(String message) {
    if (kDebugMode) {
      Logger().i(message);
    }
  }
}
