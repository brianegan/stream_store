import "dart:async";
import "package:stream_store/stream_store.dart";
import "package:test/test.dart";
import "test_utils.dart";

void main() {
  group("Store", () {
    test("should accept an initial state", () async {
      final store = new Store(identityReducer, initialState: 0);

      store.add(0);

      await expect(store, emits(0));
    });

    test("accepts actions and sends them through the reducer", () async {
      final store = new Store(identityReducer, initialState: 0);

      store.add(1);

      await expect(store, emitsInOrder([0, 1]));
    });

    test("can replace the reducer", () async {
      final store = new Store(addReducer, initialState: 0);

      store.reducer = subtractReducer;
      store.add(1);

      // Second 0 comes from the REPLACE action
      await expect(store, emitsInOrder([0, 0, -1]));
    });

    test("runs actions through the provided transformers", () async {
      final doubler = new StreamTransformer.fromHandlers(
        handleData: (Object action, EventSink<Object> sink) =>
            action is int ? sink.add(action * 2) : sink.add(action),
      );
      final store = new Store(
        identityReducer,
        initialState: 0,
        actionTransformers: [doubler, doubler, doubler], // triple doubler!!!
      );

      store.add(1);

      await expect(store, emitsInOrder([0, 8]));
    });

    test("runs the reduced state through the provided transformers", () async {
      final doubler = new StreamTransformer.fromHandlers(
        handleData: (int state, EventSink<int> sink) => sink.add(state * 2),
      );
      final store = new Store(
        identityReducer,
        initialState: 0,
        stateTransformers: [doubler, doubler, doubler], // triple doubler!!!
      );

      store.add(1);

      await expect(store, emitsInOrder([0, 8]));
    });
  });
}
