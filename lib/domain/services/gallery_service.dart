import 'package:image_picker/image_picker.dart';

/// Сервис для работы с галлереей устройства
abstract interface class GalleryService {
  /// Выбрать изображение и получить его путь
  Future<String?> pickImage();

  /// Выбрать видео
  Future<XFile?> pickVideo();
}