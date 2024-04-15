import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffmpeg_flutter/data/typedefs/native.dart';
import 'package:ffmpeg_flutter/domain/services/video_service.dart';
import 'package:ffmpeg_flutter/domain/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

ffi.DynamicLibrary _openDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libnative_ffmpeg.so');
    }
    return ffi.DynamicLibrary.process();
  }
  
final ffi.DynamicLibrary _lib = _openDynamicLibrary();

final GetVersionFunction _getVersion = _lib
  .lookup<ffi.NativeFunction<CGetVersionFunction>>('version').asFunction();

final CompressFunction _compressVideoFunction = _lib
  .lookup<ffi.NativeFunction<CCompressVideoFunction>>('compress_video').asFunction();

@Injectable(as: VideoService)
class VideoServiceImpl implements VideoService {
  /// Путь, по которому сохранится обработанное видео
  late final String _tempPath;
   
  VideoServiceImpl() {
    getTemporaryDirectory().then((dir) => _tempPath = '${dir.path}/compressed.mp4');
  }

  @override
  String getVersion() => _getVersion().toDartString();

  @override
  Future<String?> compressVideo(String videoPath) async {
    try {
      await compute(
        (inputPath) => _compressVideoFunction(inputPath.toNativeUtf8(), _tempPath.toNativeUtf8()), 
        videoPath
      ); 
    } catch (error, stackTrace) {
      GetIt.I<AppLogger>().native(stackTrace: stackTrace, error: error);
      return null;
    }

    return _tempPath;
  } 
}