import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';
import 'package:stream_store/src/reducer.dart';

class States<S> extends BehaviorSubject<S> {
  States(S initialState, Stream<Reducer<S>> reducers, Stream<Object> actions)
      : super(seedValue: initialState) {
    actions
        .transform(
          new WithLatestFromStreamTransformer(
            reducers,
            (a, r) {
              return new _ActionAndReducer<S>(a, r);
            },
          ),
        )
        .transform(
          new ScanStreamTransformer(
            (S state, _ActionAndReducer<S> latest, int i) {
              return latest.reducer(state, latest.action);
            },
            initialState,
          ),
        )
        .listen(add, onError: addError, onDone: close);
  }
}

class _ActionAndReducer<S> {
  final dynamic action;
  final Reducer<S> reducer;

  _ActionAndReducer(this.action, this.reducer);
}
