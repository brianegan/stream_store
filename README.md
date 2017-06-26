# stream_store

[![build status](https://gitlab.com/brianegan/stream_store/badges/master/build.svg)](https://gitlab.com/brianegan/stream_store/commits/master)  [![coverage report](https://gitlab.com/brianegan/stream_store/badges/master/coverage.svg)](https://brianegan.gitlab.io/stream_store/coverage/)

Redux-style state management built with Dart Primitives. The `Store` is a simple `Stream<State>` and a `Sink<Action>`. This means you can `add` (aka `dispatch`) new actions to the `Sink<Action>`. These actions will then be run through a series of `StreamTransformer` (aka `Middleware`) that you provide. Finally, the action will reach the provided `reducer`. It will take the previous state and the current action, combining them together to form a new state. The new state will then be emitted to anything that is `listen`ing to the `Store`'s `Stream<State>`.  

I have no idea if anyone wants to use this or if it's even necessary given the fact that there are other Dart Redux solutions out there, but I did it as a thought experiment to see how close to the core Dart primitives we could get and thought I might as well publish it.

