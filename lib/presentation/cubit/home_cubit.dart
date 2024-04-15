import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ffmpeg_flutter/domain/services/gallery_service.dart';
import 'package:ffmpeg_flutter/domain/services/video_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';

/// Кубит экрана [HomeScreen]
@injectable
class HomeCubit extends Cubit<HomeState> {
  final VideoService _videoService;
  final GalleryService _galleryService;

  HomeCubit(this._videoService, this._galleryService) : super(InitialState());

  XFile? _video; 

  void getFFmpegVersion() {
    final version = _videoService.getVersion();
    emit(LoadedFFmpegVersionState(version));
  }

  Future<void> pickVideo() async {
    _video = await _galleryService.pickVideo();
    if (_video == null) return;

    final length = await _video!.length();

    emit(PickedVideoState(_video!.path, length));
  }

  Future<void> compressVideo() async {
    if (_video == null) return;
    emit(CompressingVideoState());

    final compressedVideoPath = await _videoService.compressVideo(_video!.path);

    final file = File(compressedVideoPath!);   
    final length = await file.length();

    emit(CompressedVideoState(compressedVideoPath, length));
  }
}
