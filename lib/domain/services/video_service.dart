/// Сервис для работы с ffmpeg
abstract interface class VideoService {
  /// Получить версию ffmpeg
  String getVersion();

  /// Обработать видео [videoPath] и вернуть путь до сжатого видео
  Future<String?> compressVideo(String videoPath);
}