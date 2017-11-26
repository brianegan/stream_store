import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';
import 'package:stream_store/src/reducer.dart';

class States<S> extends Subject<S> {
  States._(
    StreamController<S> controller,
    Observable<S> observable,
  )
      : super(controller, observable);

  factory States(
    S initialState,
    Stream<Reducer<S>> reducers,
    Stream<Object> actions,
  ) {
    final subject = new BehaviorSubject(
      seedValue: initialState,
    );

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
        .listen(
          subject.add,
          onError: subject.addError,
          onDone: subject.close,
        );

    return new States._(subject.controller, subject.stream);
  }
}

class _ActionAndReducer<S> {
  final dynamic action;
  final Reducer<S> reducer;

  _ActionAndReducer(this.action, this.reducer);
}
