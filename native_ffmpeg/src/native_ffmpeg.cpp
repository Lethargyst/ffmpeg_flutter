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
        AVFormatContext *input_format_ctx = avformat_alloc_context();
        if (avformat_open_input(&input_format_ctx, inputVideoPath, nullptr, nullptr) != 0) {
            dartLog("Не удалось открыть файл с исходным видео");
            return;
        }

        // Получение информации о потоке
        if (avformat_find_stream_info(input_format_ctx, nullptr) < 0) {
            dartLog("Не удалось получить информацию о потоке");
            return;
        }

        // Поиск видео потока
        int video_stream_index = -1;
        AVCodecParameters *codecParams;
        for (int i = 0; i < input_format_ctx->nb_streams; i++) {
            if (input_format_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
                video_stream_index = i;
                codecParams = input_format_ctx->streams[i]->codecpar;
                break;
            }
        }
        const AVCodec *decoder = avcodec_find_decoder(codecParams->codec_id);
        if (!decoder) {
            dartLog("Не удалось найти кодек декодирования");
            return;
        }
        // int video_stream_index = av_find_best_stream(input_format_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, &decoder, 0);
        // if (video_stream_index < 0) {
        //     dartLog("Не удалось найти видео поток в файле");
        //     return;
        // }

        // Поиск инициализация кодека декодирования видео
        AVCodecContext *decoder_ctx = avcodec_alloc_context3(decoder);
        avcodec_parameters_to_context(decoder_ctx, input_format_ctx->streams[video_stream_index]->codecpar);
        if (avcodec_open2(decoder_ctx, decoder, nullptr) < 0) {
            dartLog("Не удалось инициализировать кодек декодирования видео");
            return;
        }

        // Подготовка контекста кодера для кодирования в H.265
        const AVCodec *encoder = avcodec_find_encoder(AV_CODEC_ID_HEVC);
        if (!encoder) {
            dartLog("Не удалось найти кодек H.265");
            return;
        }

        AVCodecContext *encoder_ctx = avcodec_alloc_context3(encoder);
        encoder_ctx->width = decoder_ctx->width;
        encoder_ctx->height = decoder_ctx->height;
        encoder_ctx->pix_fmt = AV_PIX_FMT_YUV420P;
        encoder_ctx->time_base = {1, 25};
        encoder_ctx->framerate = {25, 1};
        encoder_ctx->bit_rate = 1000000; // Пример битрейта (может потребоваться настройка)
        encoder_ctx->gop_size = 10; // Пример размера группы кадров (может потребоваться настройка)
        encoder_ctx->max_b_frames = 1; // Пример максимального количества B-кадров (может потребоваться настройка)

        if (avcodec_open2(encoder_ctx, encoder, nullptr) < 0) {
            dartLog("Не удалось инициализировать кодек кодирования видео в H.265");
            return;
        }

        // Создание формата вывода
        AVFormatContext *output_format_ctx = nullptr;
        avformat_alloc_output_context2(&output_format_ctx, nullptr, nullptr, outputVideoPath);
        if (!output_format_ctx) {
            dartLog("Не удалось создать формат вывода");
            return;
        }

        // Создание потока для кодирования
        AVStream *output_stream = avformat_new_stream(output_format_ctx, nullptr);
        if (!output_stream) {
            dartLog("Не удалось создать поток для кодирования");
            return;
        }

        output_stream->codecpar->codec_tag = 0;
        avcodec_parameters_from_context(output_stream->codecpar, encoder_ctx);

        // Открытие файла для записи
        if (avio_open(&output_format_ctx->pb, outputVideoPath, AVIO_FLAG_WRITE) < 0) {
            dartLog("Не удалось открыть файл для записи");
            return;
        }

        // Запись заголовка файла вывода
        if (avformat_write_header(output_format_ctx, nullptr) < 0) {
            dartLog("Не удалось записать заголовок файла вывода");
            return;
        }

        // Инициализация пакета и фрейма
        AVPacket* input_packet = av_packet_alloc();
        input_packet->data = nullptr;
        input_packet->size = 0;

        AVFrame *input_frame = av_frame_alloc();
        if (!input_frame) {
            dartLog("Не удалось выделить память под фрейм");
            return;
        }

        // Чтение, декодирование, кодирование и запись каждого кадра
        while (av_read_frame(input_format_ctx, input_packet) >= 0) {
            if (input_packet->stream_index == video_stream_index) {
                // Декодирование кадра
                while (avcodec_send_packet(decoder_ctx, input_packet) < 0) {
                    if (avcodec_receive_frame(decoder_ctx, input_frame) < 0) {
                        dartLog("Не удалось декодировать кадр");
                        return;
                    }

                    AVPacket* output_packet = av_packet_alloc();
                    while (avcodec_send_frame(decoder_ctx, input_frame) >= 0) {
                        if (avcodec_receive_packet(decoder_ctx, output_packet) < 0) {
                            dartLog("Не удалось закодировать кадр");
                            return;
                        }
                        output_packet->stream_index = input_packet->stream_index;
                        av_interleaved_write_frame(output_format_ctx, output_packet);
                    }
                    
                    av_packet_unref(output_packet);
                    av_packet_free(&output_packet);
                    av_frame_unref(input_frame);
                }
            }

            av_packet_unref(input_packet);
        }

        // Завершение записи
        av_write_trailer(output_format_ctx);

        // Освобождение ресурсов
        avcodec_free_context(&decoder_ctx);
        avcodec_free_context(&encoder_ctx);
        avformat_close_input(&input_format_ctx);
        avformat_free_context(input_format_ctx);
        avformat_free_context(output_format_ctx);
        av_frame_free(&input_frame);
    }
}
