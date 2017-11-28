import 'dart:async';

/// A mechanism to perform side-effects and async work.
///
/// Writing Effects, aka "Middleware", is required for handling side-effects,
/// such as calling out to an api or reading from a database.
///
/// However, in order to do this safely, most of the time you not only need to
/// dispatch your own actions, but also ensure you dispatch the original action
/// as well. In order to make this process safer, the `Effect` typedef
/// was introduced.
///
/// Effects take in a Stream<State> and Stream<Actions> and returns a
/// Stream<Action>. Actions in, actions out. But it will never swallow the
/// original action that was `add`ed to the Store's `Sink<Action>`.
///
/// ### Example
///
///     Stream<dynamic> searchEffect(
///       Stream<State> states,
///       Stream<dynamic> actions,
///     ) =>
///       actions
///         .where((action) => action is PerformSearchAction)
///         .asyncMap((action) =>
///           // Pseudo api that returns a Future of SearchResults
///           api.search((action as PerformSearch).searchTerm)
///           .then((results) => new SearchResultsAction(results))
///           .catchError((error) => new SearchErrorAction(error)));
///
/// ### Example combining Actions and State
///
/// In order to use the latest state in our `Effect`, we must use the RxDart
/// library. It will allow us to combine the State and Action streams.
///
/// First, we'll narrow down to `PerformSearchAction`s using the `ofType`
/// operator from RxDart. Then, we'll use the `withLatestFrom` operator. The
/// `withLatestFrom` operator combines the latest dispatched action with the
/// latest state.
///
///     // First, we'll define a class that encapsulates some information from
///     // the Action as well as some information from the state.
///     class PerformPagedSearchAction {
///       final String searchTerm;
///       final int currentPage;
///
///       PerformPagedSearchAction(this.searchTerm, this.currentPage);
///     }
///
///     // Then we'll use the class in our Effect.
///     Stream<dynamic> searchEffect(
///       Stream<State> states,
///       Stream<dynamic> actions,
///     ) =>
///       new Observable(actions)
///         .ofType(new TypeToken<PerformSearchAction>())
///         // Use `withLatestFrom` to get the latest `State` from the
///         // `states` `Stream`. We'll then combine it with the latest
///         // action from the `actions` `Stream`.
///         .withLatestFrom((action, state) {
///           return new PerformPagedSearchAction(
///             action.searchTerm,
///             state.currentPage
///           );
///         })
///         .asyncMap((action) =>
///           // Pseudo api that returns a Future of SearchResults using a
///           // paginated api.
///           api.searchPaginated(action.searchTerm, action.currentPage)
///           .then((results) => new SearchResultsAction(results))
///           .catchError((error) => new SearchErrorAction(error)));
typedef Stream<dynamic> Effect<S>(Stream<S> states, Stream<dynamic> actions);
