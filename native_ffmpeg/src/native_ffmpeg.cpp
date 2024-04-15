extern "C" {
    #include <libavcodec/avcodec.h>
}

#if defined(__GNUC__)
    #define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#elif defined(_MSC_VER)
    #define FFI_EXPORT __declspec(dllexport)
#endif

extern "C" {
    FFI_EXPORT 
    const char* version() {
        return av_version_info();
    }

    FFI_EXPORT
    void compress_video(char* inputVideoPath, char* outputVideoPath) {
    }
}
