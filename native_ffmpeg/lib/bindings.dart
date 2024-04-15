part of 'functions.dart';


DynamicLibrary _openDynamicLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libnative_ffmpeg.so');
    }
    return DynamicLibrary.process();
  }
  
final DynamicLibrary _lib = _openDynamicLibrary();


final LogWrapperFunction _initializeLogger = _lib
  .lookup<NativeFunction<CLogWrapperFunction>>("initializeLogger").asFunction();

final GetVersionFunction _getFfmpegVersion = _lib
  .lookup<NativeFunction<CGetVersionFunction>>('version').asFunction();

final CompressFunction _compressVideoFunction = _lib
  .lookup<NativeFunction<CCompressVideoFunction>>('compress_video').asFunction();
  