import 'package:ffmpeg_flutter/presentation/cubit/home_cubit.dart';
import 'package:ffmpeg_flutter/presentation/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    _cubit = GetIt.I<HomeCubit>()..getFFmpegVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocProvider.value(
          value: _cubit,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) {
                    return current is PickedVideoState; 
                  },
                  builder: (context, state) {
                    if (state is PickedVideoState) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: AppVideoPlayer(videoPath: state.videoPath)
                          ),
                          Text('Размер видео: ${state.size} Б')
                        ],
                      );
                    }
            
                    return const SizedBox.shrink();
                  }
                ),
            
                ElevatedButton(
                  onPressed: _cubit.pickVideo, 
                  child: const Text('Выбрать видео')
                ),

                BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) {
                    return current is CompressedVideoState ||
                      current is CompressingVideoState;
                  },
                  builder: (context, state) {
                    if (state is CompressedVideoState) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: AppVideoPlayer(videoPath: state.videoPath)
                          ),
                          Text('Размер видео: ${state.size} Б')
                        ],
                      );
                    }

                    if (state is CompressingVideoState) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),

                BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) {
                    return current is PickedVideoState ||
                      current is CompressingVideoState;
                  },
                  builder: (context, state) {
                    if (state is PickedVideoState) {
                      return ElevatedButton(
                        onPressed: _cubit.compressVideo,
                        child: const Text('Сжать видео')
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
            
                BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) => current is LoadedFFmpegVersionState,
                  builder: (context, state) {
                    if (state is LoadedFFmpegVersionState) {
                      return Text('FFmpeg: ${state.version}');
                    }
                
                    return const SizedBox.shrink();
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}