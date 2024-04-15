import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Сигнатуры C функций
typedef CLogWrapperFunction = Void Function(Pointer);
typedef CGetVersionFunction = Pointer<Utf8> Function();
typedef CCompressVideoFunction = Void Function(Pointer<Utf8>, Pointer<Utf8>);

// Сигнатуры Dart функций
typedef LogWrapperFunction = void Function(Pointer);
typedef GetVersionFunction = Pointer<Utf8> Function();
typedef CompressFunction = void Function(Pointer<Utf8>, Pointer<Utf8>);