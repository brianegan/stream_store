import 'dart:async';
import 'package:rxdart/rxdart.dart';

enum TestActions {
  SEND1,
  SEND2,
  RESPOND1,
  RESPOND2,
}

// Effects
Stream<dynamic> send1Effect(
  Stream<TestActions> states,
  Stream<dynamic> actions,
) {
  return actions
      .where((action) => action == TestActions.SEND1)
      .map((action) => TestActions.RESPOND1);
}

Stream<dynamic> send2Effect(
  Stream<TestActions> states,
  Stream<dynamic> actions,
) {
  return actions
      .where((action) => action == TestActions.SEND2)
      .map((action) => TestActions.RESPOND2);
}

Stream<dynamic> cancellableResponse(
  Stream<TestActions> states,
  Stream<dynamic> actions,
) {
  return new Observable(actions)
      .where((action) => action == TestActions.SEND1)
      .flatMap((action) => new Observable.timer(
              TestActions.RESPOND1, new Duration(milliseconds: 1))
          .takeUntil(actions.where((action) => action == TestActions.SEND2)));
}

Stream<dynamic> respondTwiceEffect(
  Stream<TestActions> states,
  Stream<dynamic> actions,
) {
  return new Observable(actions)
      .where((action) => action == TestActions.SEND1)
      .flatMap((action) => new Observable.merge([
            new Observable.just(TestActions.RESPOND1),
            new Observable.just(TestActions.RESPOND2).debounce(
              new Duration(milliseconds: 5),
            )
          ]));
}

Stream<dynamic> readStateEffect(
  Stream<TestActions> states,
  Stream<dynamic> actions,
) {
  return new Observable(actions)
      .where((action) => action == TestActions.SEND1)
      .withLatestFrom(states, (action, state) => state);
}

// Reducers
dynamic identityReducer(dynamic state, dynamic action) => action;

int addReducer(int state, Object action) =>
    action is int ? state + action : state;

int subtractReducer(int state, Object action) =>
    action is int ? state - action : state;
