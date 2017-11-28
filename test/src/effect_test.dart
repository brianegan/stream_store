import "package:stream_store/stream_store.dart";
import "package:test/test.dart";
import "test_utils.dart";

void main() {
  group("Effects", () {
    TestActions identityReducer(TestActions state, dynamic action) =>
        action is TestActions ? action : state;

    test("transform but cannot swallow actions", () async {
      final store = new Store<TestActions>(
        identityReducer,
        effects: [send1Effect],
      );

      store.add(TestActions.SEND1);

      await expect(
          store, emitsInOrder([TestActions.SEND1, TestActions.RESPOND1]));
    });

    test("can be combined", () async {
      final store = new Store(identityReducer, effects: [
        send1Effect,
        send2Effect,
      ]);

      store.add(TestActions.SEND1);
      store.add(TestActions.SEND2);

      await expect(
          store,
          emitsInOrder([
            TestActions.SEND1,
            TestActions.RESPOND1,
            TestActions.SEND2,
            TestActions.RESPOND2,
          ]));
    });

    test("work with async streams", () async {
      final store = new Store(
        identityReducer,
        effects: [cancellableResponse],
      );

      store.add(TestActions.SEND1);

      await expect(
        store,
        emitsInOrder(
          [
            TestActions.SEND1,
            TestActions.RESPOND1,
          ],
        ),
      );
    });

    test("can be cancelled by dispatching follow up actions", () async {
      final store = new Store(
        identityReducer,
        effects: [cancellableResponse],
      );

      store.add(TestActions.SEND1);
      store.add(TestActions.SEND2);

      await expect(
        store,
        emitsInOrder(
          [
            TestActions.SEND1,
            TestActions.SEND2,
          ],
        ),
      );
    });

    test("can send multiple actions in response to a single action", () async {
      final store = new Store(
        identityReducer,
        effects: [respondTwiceEffect],
      );

      store.add(TestActions.SEND1);

      await expect(
        store,
        emitsInOrder(
          [
            TestActions.SEND1,
            TestActions.RESPOND1,
            TestActions.RESPOND2,
          ],
        ),
      );
    });

    test("can read the state", () async {
      final store = new Store(
        identityReducer,
        initialState: TestActions.RESPOND1,
        effects: [readStateEffect],
      );

      store.add(TestActions.SEND1);

      await expect(
        store,
        emitsInOrder(
          [
            TestActions.RESPOND1,
            TestActions.SEND1,
            TestActions.RESPOND1,
          ],
        ),
      );
    });
  });
}
