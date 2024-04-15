import 'package:ffmpeg_flutter/domain/services/gallery_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: GalleryService)
class GalleryServiceImpl implements GalleryService {
  final _picker = ImagePicker();

  @override
  Future<String?> pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    return image?.path;
  }

  @override
  Future<XFile?> pickVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    return video;
  }
}