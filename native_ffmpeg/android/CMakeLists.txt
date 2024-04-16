cmake_minimum_required(VERSION 3.4.1)
include_directories(../include/${ANDROID_ABI})

set(ffmpeg_libs_dir ${CMAKE_CURRENT_SOURCE_DIR}/src/main/JniLibs/${ANDROID_ABI})
set(ffmpeg_libs avcodec avdevice avfilter avformat avutil postproc swresample swscale)

foreach (ffmpeg_lib ${ffmpeg_libs})
    add_library(
        ${ffmpeg_lib}
        SHARED
        IMPORTED
    )
    set_target_properties(
        ${ffmpeg_lib}
        PROPERTIES
        IMPORTED_LOCATION
        ${ffmpeg_libs_dir}/lib${ffmpeg_lib}.so
    )
endforeach ()

add_library(native_ffmpeg SHARED ../src/native_ffmpeg.cpp)

target_link_libraries(
    native_ffmpeg 

    ${ffmpeg_libs}
)