# Changelog

## 0.1.0

- Breaking changes: Remove state transformers. You an just transform the `Store`'s `Stream<State>` however you like.
- Only allow the use of `Effect` for side-effects instead of transformers. `Effect`s cannot swallow actions that are `add`ed to the Stream, and work with both a `Stream<Action>` and a `Stream<State>`. 
- Migrate `LoggingTransformer` to `LoggingEffect`. Improve functionality.

## 0.0.2

- Move to github
- Bump Rx

## 0.0.1

- Initial version with simple Stream-based API
