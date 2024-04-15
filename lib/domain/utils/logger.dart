abstract interface class AppLogger {
  /// Логирование ошибок натива
  void native({required StackTrace stackTrace, Object? error});

  /// Информирующие логи
  void info(String message);
}