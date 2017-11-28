import "dart:async";
import "package:stream_store/stream_store.dart";
import "package:test/test.dart";
import "test_utils.dart";

void main() {
  group("Store", () {
    test("should accept an initial state", () async {
      final store = new Store(identityReducer, initialState: 0);

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

    test("runs actions through the provided effects", () async {
      final doubler = (Stream<int> states, Stream<dynamic> actions) {
        return actions.map((action) => action is int ? action * 2 : action);
      };
      final store = new Store<int>(
        (state, action) => action is int ? action : state,
        initialState: 0,
        effects: [doubler, doubler, doubler], // triple doubler!!!
      );

      store.add(1);

      await expect(store, emitsInOrder([0, 1, 2, 2, 2]));
    });
  });
}
