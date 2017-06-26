import 'dart:async';
import 'package:logging/logging.dart';

class LoggingTransformer<T> implements StreamTransformer<T, T> {
  final Logger logger;
  final Level level;
  final String tag;

  LoggingTransformer(this.logger,
      {this.tag = "Store Log:", this.level = Level.INFO});

  @override
  Stream<T> bind(Stream<T> items) {
    items.listen(
        (item) => logger.log(level, "$tag $item @ ${new DateTime.now()}"));

    return items;
  }
}
