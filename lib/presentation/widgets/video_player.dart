import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  final String videoPath;

  const AppVideoPlayer({ 
    super.key,
    required this.videoPath 
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _initialized = false;

  @override
  void initState() {
    _initControllers();
    super.initState();
  }

  void _initControllers() {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: true,
    );

    _initialized = true;
    setState(() {});
  }

  void _disposeControllers() {
    _initialized = false;
    setState(() {});

    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    _disposeControllers();
    _initControllers();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose(); 
  }
  
  @override
  Widget build(BuildContext context){
    if (_initialized) {
      return Chewie(controller: _chewieController!);
    }

    return const SizedBox.shrink();
  }
}