import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:stream_store/src/reducer.dart';
import 'package:stream_store/src/states.dart';

class Store<S> extends StreamView<S> implements Sink<dynamic> {
  final Sink<dynamic> _actions;
  final Sink<Reducer<S>> _reducers;
  final States<S> _states;

  Store._(this._actions, this._reducers, this._states) : super(_states.stream);

  factory Store(
    Reducer<S> reducer, {
    S initialState,
    List<StreamTransformer<dynamic, dynamic>> transformers = const [],
  }) {
    // ignore: close_sinks
    final actions = new StreamController.broadcast();
    // ignore: close_sinks
    final reducers = new BehaviorSubject<Reducer<S>>(seedValue: reducer);
    // ignore: close_sinks
    final states = new States<S>(
        initialState,
        reducers.stream,
        transformers.fold(
          actions.stream,
          (stream, transformer) => stream.transform(transformer),
        ));

    return new Store._(actions, reducers, states);
  }

  void set reducer(Reducer<S> reducer) {
    _reducers.add(reducer);
    _actions.add(StreamStoreActions.REPLACE);
  }

  @override
  void add(dynamic action) {
    _actions.add(action);
  }

  @override
  void close() {
    _actions.close();
    _reducers.close();
    _states.close();
  }
}

enum StreamStoreActions { REPLACE }
