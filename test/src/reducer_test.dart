import "package:stream_store/stream_store.dart";
import "package:test/test.dart";
import "test_utils.dart";

void main() {
  group("Reducers", () {
    test("convert actions and a state into a new state", () async {
      expect(addReducer(0, 1), 1);
    });

    test("can be combined", () async {
      final store = new Store(
        combineReducers([
          addReducer,
          subtractReducer,
        ]),
        initialState: 0,
      );

      store.add(1);

      await expect(
          store, emitsInOrder([0, 0 /* The reducers cancel each other out */]));
    });
  });
}
