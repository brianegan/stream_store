import "package:stream_store/stream_store.dart";
import "package:test/test.dart";
import "test_utils.dart";

void main() {
  group("Effects", () {
    Object identityReducer(Object state, Object action) => action;

    test("transform but cannot swallow actions", () async {
      final transformer = new EffectTransformer(send1Effect);
      final store = new Store(identityReducer, transformers: [transformer]);

      store.add(TestActions.SEND1);

      await expect(
          store, emitsInOrder([TestActions.SEND1, TestActions.RESPOND1]));
    });

    test("can be combined", () async {
      final store = new Store(identityReducer, transformers: [
        new EffectTransformer.combine([
          send1Effect,
          send2Effect,
        ]),
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

    test("more than one transformer is supported", () async {
      final transformer1 = new EffectTransformer(send1Effect);
      final transformer2 = new EffectTransformer(send2Effect);
      final store = new Store(identityReducer, transformers: [
        transformer1,
        transformer2,
      ]);

      store.add(TestActions.SEND1);

      await expect(
          store, emitsInOrder([TestActions.SEND1, TestActions.RESPOND1]));
    });

    test("work with async streams", () async {
      final transformer = new EffectTransformer(cancellableResponse);
      final store = new Store(
        identityReducer,
        transformers: [transformer],
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
      final transformer = new EffectTransformer(cancellableResponse);
      final store = new Store(
        identityReducer,
        transformers: [transformer],
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
      final transformer = new EffectTransformer(respondTwiceEffect);
      final store = new Store(
        identityReducer,
        transformers: [transformer],
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
  });
}
