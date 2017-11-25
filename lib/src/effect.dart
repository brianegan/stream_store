import 'dart:async';

import 'package:rxdart/streams.dart';

/// A simplified StreamTransformer that cannot accidentally swallow dispatched
/// actions.
///
/// Writing StreamTransformers, aka "Middleware", is encouraged for handling
/// side-effects, such as calling out to an api or reading from a database.
///
/// However, in order to do this safely, most of the time you not only need to
/// dispatch your own actions, but also ensure you dispatch the original action
/// as well. In order to make this process safer, the `Effect` typedef
/// was introduced.
///
/// It works exactly like a StreamTransformer. It takes in Stream<Actions> and
/// returns a Stream<Action>. Actions in, actions out. But it will never swallow
/// the original action.
///
/// ### Example
///
///     Stream<Object> searchEffect(Stream<Object> actions) =>
///       actions
///         .where((action) => action is PerformSearchAction)
///         .asyncMap((action) =>
///           // Pseudo api that returns a Future of SearchResults
///           api.search((action as PerformSearch).searchTerm)
///           .then((results) => new SearchResultsAction(results))
///           .catchError((error) => new SearchErrorAction(error)));
typedef Stream<dynamic> Effect(Stream<dynamic> actions);

/// Wraps the `Effect` in a proper StreamTransformer so it can be used
/// as part of the construction of the `Store`.
///
/// ### Example
///
///     final store = new Store(
///       addReducer,
///       initialState: 0,
///       transformers: [new EffectTransformer(searchEffect)],
///     );
class EffectTransformer implements StreamTransformer<dynamic, dynamic> {
  final Effect effect;

  EffectTransformer(this.effect);

  factory EffectTransformer.combine(List<Effect> effects) {
    return new EffectTransformer((actions) {
      return new MergeStream(effects.map((effect) => effect(actions)));
    });
  }

  @override
  Stream<dynamic> bind(Stream<dynamic> actions) {
    final controller = new StreamController<dynamic>.broadcast();

    actions.listen(
      controller.add,
      onError: controller.addError,
    );

    effect(actions).listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    return controller.stream;
  }
}
