#pragma once

#if defined(__GNUC__)
    #define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#elif defined(_MSC_VER)
    #define FFI_EXPORT __declspec(dllexport)
#endif

/// Инициализировать функцию логгирования. Вызывается из dart кода
extern "C" {
    /// Функция логгирования
    void (*dartLog)(char *);

    FFI_EXPORT
    void initializeLogger(void (*logCallback)(char *)) {
        dartLog = logCallback;
    }
}