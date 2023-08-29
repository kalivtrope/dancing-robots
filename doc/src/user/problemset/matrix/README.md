# matrix

You are given an undirected graph with self-loops on each node in the form of an adjacency *matrix*.
Find and report the shortest path in this graph.

## Problem statement
### Maze format
- let `n >= 3` be a positive integer
- let there be an undirected unweighted graph `G=({1..n},E)`
  - every vertex of the graph contains a self-loop
- the problem is encoded in the grid as follows:
  - the grid has a square shape of `(n+2)x(n+2)` cells
  - there are solid walls on all of its 4 borders (so there is a solid left,right,bottom,top wall line)
  - **the top-left-most non-wall cell is at row 1, column 1**
  - column number increases by moving east, row number increases by moving south
  - there is an edge `e=(u,v)` in `E` if and only if there is an item at row `u`, column `v`
    - since the graph is undirected, there also exists an edge `e'=(v,u)` opposite to the edge `e`
- both start and end are placed in the same position `(row, column): (r,s)`
### Objective
- your task is to find the shortest path from node `r` to node `s`
  - the length of the shortest path is guaranteed to be at least 2 edges
  - if there's multiple shortest paths, you may choose to output any one of them
- if the shortest path has length of `k` edges and is consisted of oriented edges `(v1,v2),(v2,v3),...,(v{k}, v{k+1})`, then the robot shall collect items at positions `(v1,v2),...,(v{k},v{k+1})` and drop them all at position `(r, s)`
- in the end, the only collected or moved items shall be the ones representing the shortest path

## Examples

You may find all of the inputs and outputs in the `Examples/matrix` directory.
See the robot's progress while solving these problems by e.g. running
```
./main.lua test -p Examples/matrix/matrix_n4.in Examples/matrix/matrix_n4.out
```
### Example 1
#### Explanation
We need to find a shortest path from node `1` to node `4`.
One such path consists of edges `(1,3)` and `(3,4)`.
Thus we pick up these two items at corresponding positions and bring them to the endpoint with us.
#### Example input (n=4) (Examples/matrix/matrix_n4.in)
```
matrix
6 6
# # # # # #
# I I . SE #
# I I I I #
# . I I I #
# . I I I #
# # # # # #
```
#### Example final form (added node numbering for clarity)
```
    1 2 3 4
  # # # # # #
1 # I . . ESII #
2 # I I I . #
3 # . I I I #
4 # . I I I #
  # # # # # #
```
#### Example output
```
turnleft
movetoitem
collect
turnright
turnright
movetowall
turnright
movetoitem
collect
turnright
turnright
movetoend
drop
drop
```
