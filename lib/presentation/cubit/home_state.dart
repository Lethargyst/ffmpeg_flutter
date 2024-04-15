part of 'home_cubit.dart';

sealed class HomeState {}

final class InitialState extends HomeState {}

final class PickedVideoState extends HomeState {
  final String videoPath;
  final int size;

  PickedVideoState(this.videoPath, this.size);
}

final class CompressingVideoState extends HomeState {}

final class CompressedVideoState extends HomeState {
  final String videoPath;
  final int size;

  CompressedVideoState(this.videoPath, this.size);
}

final class LoadedFFmpegVersionState extends HomeState {
  final String version;

  LoadedFFmpegVersionState(this.version);
}
