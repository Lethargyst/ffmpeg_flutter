import 'package:ffmpeg_flutter/app.dart';
import 'package:ffmpeg_flutter/di/di.dart';
import 'package:flutter/material.dart';


void main() {
  configureApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}