import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:stream_store/src/reducer.dart';
import 'package:stream_store/src/states.dart';

class Store<S> extends StreamView<S> implements Sink<Object> {
  final Sink<Object> _actions;
  final Sink<Reducer<S>> _reducers;

  Store._(this._actions, this._reducers, Stream<S> _states) : super(_states);

  factory Store(
    Reducer<S> reducer, {
    S initialState,
    List<StreamTransformer<Object, Object>> actionTransformers = const [],
    List<StreamTransformer<S, S>> stateTransformers = const [],
  }) {
    // ignore: close_sinks
    final actions = new StreamController.broadcast();
    // ignore: close_sinks
    final reducers = new BehaviorSubject<Reducer<S>>(seedValue: reducer);
    // ignore: close_sinks
    final states = new States(
        initialState,
        reducers.stream,
        actionTransformers.fold(actions.stream,
            (stream, transformer) => stream.transform(transformer)),
        stateTransformers);

    return new Store._(actions, reducers, states.stream);
  }

  void set reducer(Reducer<S> reducer) {
    _reducers.add(reducer);
    _actions.add(StreamStoreActions.REPLACE);
  }

  @override
  void add(Object action) {
    _actions.add(action);
  }

  @override
  void close() {
    _actions.close();
  }
}

enum StreamStoreActions { REPLACE }
