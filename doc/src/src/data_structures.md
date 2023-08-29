# Data structures

There's currently three data structures being defined: `FenwickTree`, `Graph` and `Queue`.

## `FenwickTree`
This data structure is utilized for quickly answering queries of type "tell me a position of the closest item from this position" while allowing to add and remove items during runtime.

## `Graph`
Used in the `matrix` problem (both in generator and judge). Is capable of generating (pseudo)random trees/graphs and reporting shortest paths.

## `Queue`
Used by the game engine to queue instructions in case the interpreter is busy at the moment.
Implemented using linked lists.
