# stream_store

[![Build Status](https://travis-ci.org/brianegan/stream_store.svg?branch=master)](https://travis-ci.org/brianegan/stream_store) [![codecov](https://codecov.io/gh/brianegan/stream_store/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/stream_store)

Redux-style state management built with Dart Primitives. The `Store` is a simple `Stream<State>` and a `Sink<Action>`. This means you can `add` (aka `dispatch`) new actions to the `Sink<Action>`. 

If you `add` an action, it will then run through the provided `reducer`. Reducers are pure functions that should only update the state in response to actions. The updated state will then be emitted to anything that is `listen`ing to the `Store`'s `Stream<State>`.

If you need to perform side-effects, such as communicating with a web server or database, you can write an `Effect`. Each effect will receive the `Stream<State>` and the `Stream<Action>`. You can then use these streams to make async calls in response to an action.

## Disclaimer

I have no idea if anyone wants to use this or if it's even necessary given the fact that there are other Dart Redux solutions out there, but I did it as a thought experiment to see how close to the core Dart primitives we could get and thought I might as well publish it.

