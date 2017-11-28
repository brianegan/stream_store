import 'dart:async';
import 'package:logging/logging.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/transformers.dart';

class LoggingEffect<S> {
  /// The [Logger] instance that actions will be logged to.
  final Logger logger;

  /// The log [Level] at which the actions will be recorded
  final Level level;

  /// A function that formats the String for printing
  final MessageFormatter<S> formatter;

  /// but it will not print to the console or anything else.
  LoggingEffect({
    Logger logger,
    this.level = Level.INFO,
    this.formatter = singleLineFormatter,
  })
      : this.logger = logger ?? new Logger("LoggingEffect");

  /// A helper factory for creating a piece of LoggingEffect that only
  /// prints to the console.
  factory LoggingEffect.printer({
    Logger logger,
    Level level = Level.INFO,
    MessageFormatter formatter = singleLineFormatter,
  }) {
    final effect = new LoggingEffect(
      logger: logger,
      level: level,
      formatter: formatter,
    );

    effect.logger.onRecord
        .where((record) => record.loggerName == effect.logger.name)
        .listen(print);

    return effect;
  }

  /// A simple formatter that puts all data on one line
  static String singleLineFormatter<State>(
    State state,
    action,
    DateTime timestamp,
  ) {
    return "{Action: $action, State: ${state}, ts: ${new DateTime.now()}}";
  }

  /// A formatter that puts each attribute on it's own line
  static String multiLineFormatter<State>(
    State state,
    action,
    DateTime timestamp,
  ) {
    return "{\n" +
        "  Action: $action,\n" +
        "  State: ${state},\n" +
        "  Timestamp: ${new DateTime.now()}\n" +
        "}";
  }

  Stream<dynamic> call(Stream<S> states, Stream<dynamic> actions) {
    final combined = new WithLatestFromStreamTransformer(
      actions,
      (S state, dynamic action) => new _StateAndAction(state, action),
    );

    states.transform(combined).listen((stateAndAction) {
      logger.log(
        level,
        formatter(
          stateAndAction.state,
          stateAndAction.action,
          new DateTime.now(),
        ),
      );
    });

    return new NeverStream();
  }
}

class _StateAndAction<S> {
  final S state;
  final dynamic action;

  _StateAndAction(this.state, this.action);
}

/// A function that formats the message that will be logged. By default, the
/// action, state, and timestamp will be printed on a single line.
///
/// This package ships with two formatters out of the box:
///
///   - [LoggingEffect.singleLineFormatter]
///   - [LoggingEffect.multiLineFormatter]
///
/// ### Example
///
///     // Create a formatter that only prints out the dispatched action
///     String onlyLogActionFormatter<State>(
///         State state,
///         action,
///         DateTime timestamp,
///         ) {
///       return "{Action: $action}";
///     }
///
///     // Create your effect using the formatter.
///     final effect = new LoggingEffect(formatter: onlyLogActionFormatter);
///
///     // Add the effect to your Store
///     final store = new Store<int>(
///       (int state, action) => state + 1,
///       initialState: 0,
///       effects: [effect],
///     );
typedef String MessageFormatter<State>(
  State state,
  dynamic action,
  DateTime timestamp,
);
