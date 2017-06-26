/// Defines an application's state change
///
/// Implement this typedef to modify your app state in response to an action
/// that has been `add`ed to your `Store`.
///
/// ### Example
///
///     counterReducer(int state, Object action) {
///       switch (action) {
///         case 'INCREMENT':
///           return state + 1;
///         case 'DECREMENT':
///           return state - 1;
///         default:
///           return state;
///       }
///     }
typedef S Reducer<S>(S state, Object action);

Reducer<T> combineReducers<T>(List<Reducer<T>> reducers) =>
    (T state, Object action) => reducers.fold(
          state,
          (currentState, reducer) => reducer(currentState, action),
        );
