type
  Direction* = enum
    Outgoing, Incoming

  Node[N] = object        ## The graph's node type.
    weight: N             ## Associated node data.
    next: array[2, int32] ## Next edge in outgoing and incoming edge lists.

  Edge[E] = object        ## The graph's edge type.
    weight: E             ## Associated edge data.
    next: array[2, int32] ## Next edge in outgoing and incoming edge lists.
    node: array[2, int32] ## Start and End node index

  Graph*[N, E] = object ## A graph datastructure using an adjacency list representation
    nodes: seq[Node[N]]
    edges: seq[Edge[E]]

const
  invalid* = high(int32) ## An invalid index used to denote absence of an edge, for example
 ## to end an adjacency list.

proc len*[N, E](self: Graph[N, E]): int =
  ## Return the number of nodes (vertices) in the graph.
  self.nodes.len

proc addNode*[N, E](self: var Graph[N, E], weight: N): int =
  ## Add a node (also called vertex) with associated data `weight` to the graph.
  ## Return the index of the new node.
  let node = Node[N](weight: weight, next: [invalid, invalid])
  result = self.nodes.len
  self.nodes.add(node)

proc `[]`*[N, E](self: Graph[N, E], a: Natural): N =
  ## Access the weight for node `a`.
  self.nodes[a].weight

proc `[]`*[N, E](self: var Graph[N, E], a: Natural): var N =
  ## Access the weight for node `a`, mutably.
  self.nodes[a].weight

proc `[]=`*[N, E](self: var Graph[N, E], a: Natural, v: N) =
  ## Set the weight for node `a`.
  self.nodes[a].weight = v

proc addEdge*[N, E](self: var Graph[N, E], a, b: Natural, weight: E) =
  ## Add an edge from `a` to `b` to the graph, with its associated
  ## data `weight`.
  assert(max(a, b) < self.nodes.len, "node indices out of bounds")
  let result = self.edges.len
  var edge = Edge[E](
     weight: weight,
     node: [a.int32, b.int32],
     next: [invalid, invalid])
  template an: untyped = self.nodes[a]
  template bn: untyped = self.nodes[b]
  if a == b: # disallow self-loops?
    edge.next = an.next
    an.next[0] = result.int32
    an.next[1] = result.int32
  else:
    # a and b are different indices
    edge.next = [an.next[0], bn.next[1]]
    an.next[0] = result.int32
    bn.next[1] = result.int32
  self.edges.add(edge)

proc findEdge[N, E](self: Graph[N, E], a, b: Natural): int =
  ## Lookup an edge from `a` to `b`.
  ##
  ## Computes in **O(e')** time, where **e'** is the number of edges
  ## connected to `a`.
  assert(max(a, b) < self.nodes.len, "node indices out of bounds")
  let node = self.nodes[a]
  var edix = node.next[0]
  while edix < self.edges.len:
    let edge = self.edges[int(edix)]
    if edge.node[1] == b:
      return edix
    edix = edge.next[0]
  result = invalid

proc updateEdge*[N, E](self: var Graph[N, E], a, b: Natural, weight: E) =
  ## Add or update an edge from `a` to `b`.
  ## If the edge already exists, its weight is updated.
  ##
  ## Return the index of the affected edge.
  ##
  ## Computes in **O(e')** time, where **e'** is the number of edges
  ## connected to `a`.
  assert(max(a, b) < self.nodes.len, "node indices out of bounds")
  let ix = self.findEdge(a, b)
  if ix < self.nodes.len:
    self.edges[int(ix)] = weight
  else:
    self.addEdge(a, b, weight)

proc extendWithEdges*[N, E](self: var Graph[N, E], iterable: openArray[(int,
    int, E)]) =
  ## Extend the graph from an iterable of edges.
  ##
  ## Node weights `N` are set to default values.
  ## Edge weights `E` may either be specified in the list,
  ## or they are filled with default values.
  ##
  ## Nodes are inserted automatically to match the edges.
  for (source, target, weight) in iterable.items:
    let nx = max(source, target)
    while nx >= self.nodes.len:
      discard self.addNode(default(N))
    self.addEdge(source, target, weight)

proc extendWithEdges*[N, E](self: var Graph[N, E], iterable: openArray[(int, int)]) =
  for (source, target) in iterable.items:
    let nx = max(source, target)
    while nx >= self.nodes.len:
      discard self.addNode(default(N))
    self.addEdge(source, target, default(E))

proc graphFromEdges*[N, E](iterable: openArray[(int, int, E)]): Graph[N, E] =
  ## Create a new `Graph` from an iterable of edges.
  ##
  ## Node weights `N` are set to default values.
  ## Edge weights `E` may either be specified in the list,
  ## or they are filled with default values.
  ##
  ## Nodes are inserted automatically to match the edges.
  ##
  ## .. code-block:: Nim
  ##  import graph
  ##
  ##  let graph2 = graphFromEdges[int, int](@[
  ##     (0, 1), (0, 2), (0, 3),
  ##     (1, 2), (1, 3),
  ##     (2, 3)])
  ##
  result.extendWithEdges(iterable)

proc graphFromEdges*[N, E](iterable: openArray[(int, int)]): Graph[N, E] =
  result.extendWithEdges(iterable)

iterator neighbors*[N, E](self: Graph[N, E], a: Natural, dir = Outgoing): int =
  ## Return all neighbors that have an edge between them and
  ## `a`, in the specified direction.
  ##
  ## Neighbors are listed in reverse order of their
  ## addition to the graph, so the most recently added edge's neighbor is
  ## listed first.
  assert(a < self.nodes.len, "node index out of bounds")
  var edix = self.nodes[a].next[dir.ord]
  while edix < self.edges.len:
    let edge = self.edges[int(edix)]
    yield edge.node[1 - dir.ord].int
    edix = edge.next[dir.ord]

iterator edges*[N, E](self: Graph[N, E], a: Natural, dir = Outgoing): (int, E) =
  ## Return all neighbors that have an edge between them and
  ## `a`, in the specified direction.
  ##
  ## Neighbors are listed in reverse order of their
  ## addition to the graph, so the most recently added edge's neighbor is
  ## listed first.
  assert(a < self.nodes.len, "node index out of bounds")
  var edix = self.nodes[a].next[dir.ord]
  while edix < self.edges.len:
    let edge = self.edges[int(edix)]
    yield (edge.node[1 - dir.ord].int, edge.weight)
    edix = edge.next[dir.ord]

proc `$`[N, E](self: Graph[N, E]): string =
  for i in 0 ..< len(self):
    if result.len > 0: result.add("\n")
    var row = ""
    for (j, w) in edges(self, i):
      if row.len > 0: row.add(", ")
      row.add($self[j] & ": " & $w)
    result.add($self[i] & " -> [" & row & "]")

when isMainModule:
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
     (nodeA, nodeB, 0.0),
     (nodeA, nodeC, 0.25),
     (nodeB, nodeD, 0.5),
     (nodeB, nodeE, 0.75),
     (nodeC, nodeF, 1.0),
     (nodeC, nodeG, 1.25),
     (nodeE, nodeF, 1.5),
     (nodeE, nodeH, 1.75),
     (nodeF, nodeG, 2.0)])

  block: #a
    var nodes: seq[int]
    for node in graph.neighbors(nodeA):
      nodes.add node
    assert nodes == @[nodeC, nodeB]
  block: #b
    var nodes: seq[int]
    for node in graph.neighbors(nodeB):
      nodes.add node
    assert nodes == @[nodeE, nodeD]
  block: #c
    var nodes: seq[int]
    for node in graph.neighbors(nodeC):
      nodes.add node
    assert nodes == @[nodeG, nodeF]
  block: #e
    var edges: seq[(int, float)]
    for edge in edges(graph, nodeE):
      edges.add edge
    assert edges == @[(nodeH, 1.75), (nodeF, 1.5)]
  block: #f
    var edges: seq[(int, float)]
    for edge in edges(graph, nodeF, Incoming):
      edges.add edge
    assert edges == @[(nodeE, 1.5), (nodeC, 1.0)]

  #echo graph

  const graph2 = graphFromEdges[string, float]({
     0: 1, 0: 2, 1: 3, 1: 4,
     2: 5, 2: 6, 4: 5,
     4: 7, 5: 6})

#[
(nodes: @[
  0: (weight: "a", next: [1, 2147483647]),
  1: (weight: "b", next: [3, 0]),
  2: (weight: "c", next: [5, 1]),
  3: (weight: "d", next: [2147483647, 2]),
  4: (weight: "e", next: [7, 3]),
  5: (weight: "f", next: [8, 7]),
  6: (weight: "g", next: [2147483647, 8]),
  7: (weight: "h", next: [2147483647, 6])],
edges: @[
  0: (weight: 1.0, next: [2147483647, 2147483647], node: [0, 1]),
  1: (weight: 1.0, next: [0, 2147483647], node: [0, 2]),
  2: (weight: 1.0, next: [2147483647, 2147483647], node: [1, 3]),
  3: (weight: 1.0, next: [2, 2147483647], node: [1, 4]),
  4: (weight: 1.0, next: [2147483647, 2147483647], node: [2, 5]),
  5: (weight: 1.0, next: [4, 2147483647], node: [2, 6]),
  6: (weight: 1.0, next: [2147483647, 2147483647], node: [4, 7]),
  7: (weight: 1.0, next: [6, 4], node: [4, 5]),
  8: (weight: 1.0, next: [2147483647, 5], node: [5, 6])])
]#
