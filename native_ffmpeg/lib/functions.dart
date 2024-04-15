import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:native_ffmpeg/typedefs.dart';

part 'bindings.dart';

/// Получить версию FFmpeg
String getVersion() => _getFfmpegVersion().toDartString();

/// Сжать видео по пути [inputPath] и результат сохранить по пути [outputPath]
Future<void> compressVideo(String inputPath, String outputPath) async {
  await compute<String, void>(
    (inputPath) {
      initializeNativeLogger();
      _compressVideoFunction(inputPath.toNativeUtf8(), outputPath.toNativeUtf8());
    }, 
    inputPath
  ); 
}

/// Логирование с натива
void _wrappedLog(Pointer<Utf8> arg){
  debugPrint('Native Log: ${arg.toDartString()}');
}
final pWrappedLogger = Pointer.fromFunction<CLogWrapperFunction>(_wrappedLog);
void initializeNativeLogger() => _initializeLogger(pWrappedLogger);