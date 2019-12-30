
# Patgraph — graph data structure library for Nim

## About
This nimble package contains a ``Graph[N, E]`` graph datastructure using an adjacency list representation.

### Example

```nim
import patgraph

var graph: Graph[string, float]

let nodeA = graph.addNode("a")
let nodeB = graph.addNode("b")
let nodeC = graph.addNode("c")
let nodeD = graph.addNode("d")
let nodeE = graph.addNode("e")
let nodeF = graph.addNode("f")
let nodeG = graph.addNode("g")
let nodeH = graph.addNode("h")

graph.extendWithEdges([
   (nodeA, nodeB, 1.0),
   (nodeA, nodeC, 1.0),
   (nodeB, nodeD, 1.0),
   (nodeB, nodeE, 1.0),
   (nodeC, nodeF, 1.0),
   (nodeC, nodeG, 1.0),
   (nodeE, nodeF, 1.5),
   (nodeE, nodeH, 2.0),
   (nodeF, nodeG, 1.0)])

echo graph
# a -> [c: 0.25, b: 0.0]
# b -> [e: 0.75, d: 0.5]
# c -> [g: 1.25, f: 1.0]
# d -> []
# e -> [h: 1.75, f: 1.5]
# f -> [g: 2.0]
# g -> []
# h -> []
```

### License

This library is distributed under the MIT license. For more information see `copying.txt`.
