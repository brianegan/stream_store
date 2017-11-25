import 'dart:async';
import 'package:logging/logging.dart';

class LoggingTransformer implements StreamTransformer<dynamic, dynamic> {
  /// The [Logger] instance that actions will be logged to.
  final Logger logger;

  /// The log [Level] at which the actions will be recorded
  final Level level;

  /// A function that formats the String for printing
  final MessageFormatter formatter;

  /// but it will not print to the console or anything else.
  LoggingTransformer({
    Logger logger,
    this.level = Level.INFO,
    this.formatter = singleLineFormatter,
  })
      : this.logger = logger ?? new Logger("LoggingTransformer");

  /// A helper factory for creating a piece of LoggingTransformer that only
  /// prints to the console.
  factory LoggingTransformer.printer({
    Logger logger,
    Level level = Level.INFO,
    MessageFormatter formatter = singleLineFormatter,
  }) {
    final middleware = new LoggingTransformer(
      logger: logger,
      level: level,
      formatter: singleLineFormatter,
    );

    middleware.logger.onRecord
        .where((record) => record.loggerName == middleware.logger.name)
        .listen(print);

    return middleware;
  }

  /// A simple formatter that puts all data on one line
  static String singleLineFormatter<State>(
    action,
    DateTime timestamp,
  ) {
    return "{Action: $action, ts: ${new DateTime.now()}}";
  }

  /// A formatter that puts each attribute on it's own line
  static String multiLineFormatter<State>(
    action,
    DateTime timestamp,
  ) {
    return "{\n" +
        "  Action: $action,\n" +
        "  Timestamp: ${new DateTime.now()}\n" +
        "}";
  }

  @override
  Stream<dynamic> bind(Stream<dynamic> actions) {
    actions.listen(
        (action) {
          logger.log(level, formatter(action, new DateTime.now()));
        });

    return actions;
  }
}

/// A function that formats the message that will be logged. By default, the
/// action, state, and timestamp will be printed on a single line.
///
/// This package ships with two formatters out of the box:
///
///   - [LoggingTransformer.singleLineFormatter]
///   - [LoggingTransformer.multiLineFormatter]
///
/// ### Example
///
///     // Create a formatter that only prints out the dispatched action
///     String onlyLogActionFormatter<State>(
///         action,
///         DateTime timestamp,
///         ) {
///       return "{Action: $action}";
///     }
///
///     // Create your middleware using the formatter.
///     final transformer = new LoggingTransformer(
///       formatter: onlyLogActionFormatter,
///     );
///
///     // Add the middleware to your Store
///     final store = new Store<int>(
///           (int state, action) => state + 1,
///       initialState: 0,
///       transformer: [middleware],
///     );
typedef String MessageFormatter(
  dynamic action,
  DateTime timestamp,
);
