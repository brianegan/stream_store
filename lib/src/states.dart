import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';
import 'package:stream_store/src/reducer.dart';

class States<S> extends BehaviorSubject<S> {
  States(
    S initialState,
    Stream<Reducer<S>> reducers,
    Stream<Object> actions, [
    List<StreamTransformer<S, S>> stateTransformers = const [],
  ])
      : super(seedValue: initialState) {
    final states = actions
        .transform(new WithLatestFromStreamTransformer(reducers, (a, r) {
          return new _ActionAndReducer<S>(a, r);
        }))
        .transform(new ScanStreamTransformer(
            (S state, _ActionAndReducer<S> latest, int i) =>
                latest.reducer(state, latest.action),
            initialState));

    stateTransformers
        .fold(states, (states, transformer) => transformer.bind(states))
        .listen(add, onError: addError, onDone: close);
  }
}

class _ActionAndReducer<T> {
  final Object action;
  final Reducer<T> reducer;

  _ActionAndReducer(this.action, this.reducer);
}
