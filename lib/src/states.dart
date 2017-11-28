import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';
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
  ) {
    // ignore: close_sinks
    final subject = new BehaviorSubject(
      seedValue: initialState,
    );

    return new States._(subject.controller, subject.stream);
  }
}


