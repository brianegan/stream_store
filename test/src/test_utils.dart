import 'dart:async';
import 'package:rxdart/rxdart.dart';

enum TestActions {
  SEND1,
  SEND2,
  RESPOND1,
  RESPOND2,
}

// Effects
Stream<Object> send1Effect(Stream<Object> actions) {
  return actions
      .where((action) => action == TestActions.SEND1)
      .map((action) => TestActions.RESPOND1);
}

Stream<Object> send2Effect(Stream<Object> actions) {
  return actions
      .where((action) => action == TestActions.SEND2)
      .map((action) => TestActions.RESPOND2);
}

Stream<Object> cancellableResponse(Stream<Object> actions) =>
    new Observable(actions)
        .where((action) => action == TestActions.SEND1)
        .flatMap((action) => new Observable.timer(
                TestActions.RESPOND1, new Duration(milliseconds: 1))
            .takeUntil(actions.where((action) => action == TestActions.SEND2)));

Stream<Object> respondTwiceEffect(Stream<Object> actions) =>
    new Observable(actions)
        .where((action) => action == TestActions.SEND1)
        .flatMap((action) => new Observable.merge([
              new Observable.just(TestActions.RESPOND1),
              new Observable.just(TestActions.RESPOND2).debounce(
                new Duration(milliseconds: 5),
              )
            ]));

// Reducers
Object identityReducer(Object state, Object action) => action;

int addReducer(int state, Object action) =>
    action is int ? state + action : state;

int subtractReducer(int state, Object action) =>
    action is int ? state - action : state;
