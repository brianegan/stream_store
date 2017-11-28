import 'dart:async';
import 'package:logging/logging.dart';
import "package:stream_store/stream_store.dart";
import "package:test/test.dart";

void main() {
  group("LoggingEffect", () {
    int addReducer(int state, action) => action is int ? state + action : state;

    test("logs actions and state to the given logger", () async {
      final effect = new LoggingEffect.printer();
      // ignore: close_sinks
      final store = new Store(
        addReducer,
        initialState: 0,
        effects: [effect],
      );

      scheduleMicrotask(() {
        store.add(1);
      });

      await expect(
        effect.logger.onRecord,
        emits(new logMessageContains(["{Action: 1, "])),
      );
    });

    test("can be configured with the correct logging level", () async {
      final logger = new Logger("Test");
      // ignore: close_sinks
      final store = new Store(
        addReducer,
        initialState: 0,
        effects: [
          new LoggingEffect.printer(
            logger: logger,
            level: Level.SEVERE,
            formatter: LoggingEffect.multiLineFormatter,
          )
        ],
      );

      scheduleMicrotask(() {
        store.add(1);
      });

      await expect(
        logger.onRecord,
        emits(new logLevel(Level.SEVERE)),
      );
    });
  });
}

class logMessageContains extends Matcher {
  final List<Pattern> patterns;

  logMessageContains(this.patterns);

  @override
  Description describe(Description description) {
    return description
        .add('is a LogRecord with a message that contains: "$patterns"');
  }

  @override
  bool matches(item, Map matchState) {
    if (item is LogRecord) {
      return patterns.every((pattern) => item.message.contains(pattern));
    }

    return false;
  }
}

class logLevel extends Matcher {
  final Level level;

  logLevel(this.level);

  @override
  Description describe(Description description) {
    return description.add('is a LogRecord with the level: $level');
  }

  @override
  bool matches(item, Map matchState) {
    if (item is LogRecord) {
      return item.level == level;
    }

    return false;
  }
}
