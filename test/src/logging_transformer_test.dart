import 'package:logging/logging.dart';
import "package:stream_store/stream_store.dart";
import "package:test/test.dart";
import "test_utils.dart";

void main() {
  group("LoggingTransformer", () {
    Logger logger;

    setUp(() {
      logger = new Logger("LoggingTransformerTest");
    });

    tearDown(() {
      logger = null;
    });

    test("logs actions and states as they come through with an optional tag",
        () async {
      final actionTag = "Action:";
      final stateTag = "State:";
      final store = new Store(addReducer, initialState: 1, actionTransformers: [
        new LoggingTransformer(
          logger,
          tag: actionTag,
        )
      ], stateTransformers: [
        new LoggingTransformer<int>(
          logger,
          tag: stateTag,
        )
      ]);

      store.add(1);

      await expect(
          logger.onRecord,
          emitsInOrder([
            new logMessageContains(["$actionTag 1"]),
            new logMessageContains(["$stateTag 2"])
          ]));

      store.close();
    });

    test("can be configured with the correct logging level", () async {
      final store = new Store(
        addReducer,
        initialState: 0,
        stateTransformers: [
          new LoggingTransformer<int>(
            logger,
            level: Level.SEVERE,
          )
        ],
      );

      store.add(1);

      await expect(logger.onRecord, emitsInOrder([new logLevel(Level.SEVERE)]));

      store.close();
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
