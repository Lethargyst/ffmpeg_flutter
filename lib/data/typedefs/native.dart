import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// Сигнатуры C функций
typedef CGetVersionFunction = ffi.Pointer<Utf8> Function();
typedef CCompressVideoFunction = ffi.Void Function(
  ffi.Pointer<Utf8>,
  ffi.Pointer<Utf8>,
);

// Сигнатуры Dart функций
typedef GetVersionFunction = ffi.Pointer<Utf8> Function();
typedef CompressFunction = void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);