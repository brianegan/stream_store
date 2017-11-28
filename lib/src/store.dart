import 'dart:async';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';
import 'package:stream_store/src/reducer.dart';
import 'package:stream_store/src/states.dart';
import 'package:stream_store/stream_store.dart';

class Store<S> extends StreamView<S> implements Sink<dynamic> {
  final Sink<dynamic> _actions;
  final Sink<Reducer<S>> _reducers;
  final States<S> _states;

  Store._(this._actions, this._reducers, this._states) : super(_states.stream);

  factory Store(
    Reducer<S> reducer, {
    S initialState,
    List<Effect<S>> effects = const [],
  }) {
    // ignore: close_sinks
    final actionsController = new StreamController.broadcast();
    // ignore: close_sinks
    final reducers = new BehaviorSubject<Reducer<S>>(seedValue: reducer);
    // ignore: close_sinks
    final states = new States<S>(initialState, reducers.stream);

    final actions = effects.isEmpty
        ? actionsController.stream
        : actionsController.stream.transform(_buildEffects<S>(
            effects,
            states.stream,
          ));

    actions
        .transform(
          new WithLatestFromStreamTransformer(
            reducers.stream,
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
          (val) => states.add(val),
          onError: states.addError,
          onDone: states.close,
        );

    return new Store._(actionsController, reducers, states);
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

  static StreamTransformer<dynamic, dynamic> _buildEffects<S>(
    List<Effect> effects,
    Stream<S> states,
  ) {
    final combinedEffect = (states, actions) {
      return new MergeStream(
        // Note: `toList` is very important here. If you simply use `map`, the
        // `MappedListIterable` can evaluate this function multiple times
        // creating duplicated actions!
        effects.map((effect) => effect(states, actions)).toList(),
      );
    };

    return new StreamTransformer((Stream<dynamic> actions, bool cancelOnError) {
      final controller = new StreamController<dynamic>.broadcast();

      actions.listen(
        (item) {
          controller.add(item);
        },
        onError: controller.addError,
      );

      combinedEffect(states, actions).listen(
        (item) {
          controller.add(item);
        },
        onError: controller.addError,
        onDone: controller.close,
      );

      return controller.stream.listen(null);
    });
  }
}

enum StreamStoreActions { REPLACE }

class _ActionAndReducer<S> {
  final dynamic action;
  final Reducer<S> reducer;

  _ActionAndReducer(this.action, this.reducer);
}
