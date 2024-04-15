import 'package:ffmpeg_flutter/domain/services/video_service.dart';
import 'package:ffmpeg_flutter/domain/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:native_ffmpeg/functions.dart' as ffmpeg;
import 'package:path_provider/path_provider.dart';

@Injectable(as: VideoService)
class VideoServiceImpl implements VideoService {
  /// Путь, по которому сохранится обработанное видео
  late final String _tempPath;
   
  VideoServiceImpl() {
    getTemporaryDirectory().then((dir) => _tempPath = '${dir.path}/compressed.mp4');
  }

  @override
  String getVersion() => ffmpeg.getVersion();

  @override
  Future<String?> compressVideo(String videoPath) async {
    try {
      await ffmpeg.compressVideo(videoPath, _tempPath);
    } catch (error, stackTrace) {
      GetIt.I<AppLogger>().native(stackTrace: stackTrace, error: error);
      return null;
    }

    return _tempPath;
  } 
}