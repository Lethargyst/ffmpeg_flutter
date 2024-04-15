// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ffmpeg_flutter/data/services/gallery_service.dart' as _i6;
import 'package:ffmpeg_flutter/data/services/video_service.dart' as _i4;
import 'package:ffmpeg_flutter/domain/services/gallery_service.dart' as _i5;
import 'package:ffmpeg_flutter/domain/services/video_service.dart' as _i3;
import 'package:ffmpeg_flutter/domain/utils/logger.dart' as _i7;
import 'package:ffmpeg_flutter/presentation/cubit/home_cubit.dart' as _i9;
import 'package:ffmpeg_flutter/presentation/utils/logger.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.VideoService>(() => _i4.VideoServiceImpl());
    gh.factory<_i5.GalleryService>(() => _i6.GalleryServiceImpl());
    gh.factory<_i7.AppLogger>(() => _i8.AppLoggerImpl());
    gh.factory<_i9.HomeCubit>(() => _i9.HomeCubit(
          gh<_i3.VideoService>(),
          gh<_i5.GalleryService>(),
        ));
    return this;
  }
}
