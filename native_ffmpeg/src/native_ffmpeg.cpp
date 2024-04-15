extern "C" {
    #include <libavcodec/avcodec.h>
    #include <libavformat/avformat.h>
    #include <libavutil/opt.h>
}

#include "logger.h"

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
        dartLog("Загрузка исходного видео...");
        AVFormatContext *formatCtx = avformat_alloc_context();
        if (avformat_open_input(&formatCtx, inputVideoPath, NULL, NULL) != 0) {
            dartLog("Не удалось загрузить исходное видео!");
            return;
        }

        // Получение исходного потока видео
        int videoStreamIndex = -1;
        AVCodecParameters *codecParams;
        for (int i = 0; i < formatCtx->nb_streams; i++) {
            if (formatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
                videoStreamIndex = i;
                codecParams = formatCtx->streams[i]->codecpar;
                break;
            }
        }

        dartLog("Получение кодека исходного потока видео...");
        const AVCodec *codec = avcodec_find_encoder(AV_CODEC_ID_H264);
        if (!codec) {
            dartLog("Не удалось получить кодек!");
            return;
        }

        // Создание контекста кодировщика
        AVCodecContext *codecCtx = avcodec_alloc_context3(codec);
        avcodec_parameters_to_context(codecCtx, codecParams);

        // Установка параметров сжатия
        codecCtx->bit_rate = 400000; // Битрейт сжатия (в бит/с)
        codecCtx->width = 640; // Ширина кадра
        codecCtx->height = 480; // Высота кадра
        codecCtx->time_base = {1, 25}; // Частота кадров
        codecCtx->gop_size = 10; // Количество кадров в группе GOP
        codecCtx->max_b_frames = 1; // Максимальное количество B-кадров
        codecCtx->pix_fmt = AV_PIX_FMT_YUV420P; // Формат пикселей

        dartLog("Открытие кодека...");
        if (avcodec_open2(codecCtx, codec, NULL) < 0) {
            dartLog("Не удалось открыть кодек!");
            return;
        }

        dartLog("Создание контекста нового потока видео...");
        AVFormatContext *outFormatCtx = avformat_alloc_context();
        if (!outFormatCtx) {
            dartLog("Не удалось создать контекст!");
            return;
        }

        // Установка формата выходного файла
        avformat_alloc_output_context2(&outFormatCtx, NULL, NULL, outputVideoPath);

        dartLog("Создание нового потока видео...");
        AVStream *outStream = avformat_new_stream(outFormatCtx, codec);
        if (!outStream) {
            dartLog("Не удалось создать новый поток видео!");
            return;
        }

        // Копирование параметров видео потока
        avcodec_parameters_copy(outStream->codecpar, codecParams);
        av_dict_copy(&outStream->metadata, formatCtx->streams[videoStreamIndex]->metadata, 0);

        dartLog("Открытие нового медиафайла");
        if (avio_open(&outFormatCtx->pb, outputVideoPath, AVIO_FLAG_WRITE) < 0) {
            dartLog("Не удалось открыть новый медиафайл!");
            return;
        }

        // Запись заголовка файла
        avformat_write_header(outFormatCtx, NULL);

        // Сжатие каждого кадра
        AVPacket pkt;
        int frameFinished;
        while (av_read_frame(formatCtx, &pkt) >= 0) {
            if (pkt.stream_index == videoStreamIndex) {
                avcodec_send_packet(codecCtx, &pkt);
                avcodec_receive_frame(codecCtx, NULL); // Если нужен обработанный кадр, нужно использовать avcodec_receive_frame()
                av_packet_unref(&pkt);
            }
        }

        // Завершение записи и освобождение ресурсов
        av_write_trailer(outFormatCtx);
        avcodec_free_context(&codecCtx);
        avformat_close_input(&formatCtx);
        avformat_free_context(outFormatCtx);
    }
}
