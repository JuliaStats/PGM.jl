using Base.Test
using PGM

@testset "Graphs" begin

# @testset "Tree.Basics" begin
#
#     g1 = Tree(7, 2,
#               [3, 3, 4, 4, 4, 4, 6],  # parents
#               [1, 1, 2, 0, -1, -1, -2])  # parent link-types
#
#     @test nvertices(g1) == 7
#     @test nedgetypes(g1) == 2
#     @test nedges(g1) == 6
#
#     @test [parent(g1, v) for v in 1:7] == [3, 3, 4, 4, 4, 4, 6]
#     @test [parent_linktype(g1, v) for v in 1:7] == [1, 1, 2, 0, -1, -1, -2]
#     @test [children(g1, v) for v in 1:7] ==
#         [Int[], Int[], [1,2], [3,5,6], Int[], [7], Int[]]
#     @test [children_linktypes(g1, v) for v in 1:7] ==
#         [Int[], Int[], [-1,-1], [-2,1,1], Int[], [2], Int[]]
#     @test [degree(g1, v) for v in 1:7] == [1, 1, 3, 3, 1, 2, 1]
#
#     @test root(g1) == 4
#     @test [Int(isroot(g1, v)) for v in 1:7] == [0, 0, 0, 1, 0, 0, 0]
#     @test [Int(isleaf(g1, v)) for v in 1:7] == [1, 1, 0, 0, 1, 0, 1]
# end


@testset "UGraph.Basics" begin

    # shared_kind is false
    nv = 5
    g1 = UGraph(5, [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (4, 5)])
    es1 = [Edge(1, 2, 1), Edge(1, 3, 2), Edge(2, 3, 3),
           Edge(2, 4, 4), Edge(3, 4, 5), Edge(4, 5, 6)]
    @test nvertices(g1) == 5
    @test nedgekinds(g1) == 6
    @test nedges(g1) == 6
    @test vertices(g1) == 1:5
    @test edges(g1) == es1
    @test [edges_of(g1, k) for k = 1:6] == [[e] for e in es1]
    @test [indegree_at(g1, v) for v=1:nv] == [0, 1, 2, 2, 1]
    @test [outdegree_at(g1, v) for v=1:nv] == [2, 2, 1, 1, 0]
    @test [degree_at(g1, v) for v=1:nv] == [2, 3, 3, 3, 1]
    @test [inedges_at(g1, v) for v=1:nv] ==
        [Edge[], [Edge(1, 2, 1)], [Edge(1, 3, 2), Edge(2, 3, 3)],
         [Edge(2, 4, 4), Edge(3, 4, 5)], [Edge(4, 5, 6)]]
    @test [outedges_at(g1, v) for v=1:nv] ==
        [[Edge(1, 2, 1), Edge(1, 3, 2)], [Edge(2, 3, 3), Edge(2, 4, 4)],
         [Edge(3, 4, 5)], [Edge(4, 5, 6)], Edge[]]

    # shared_kind is true
    nv = 5
    g2 = UGraph(5, [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (4, 5)];
                shared_kind=true)
    es2 = [Edge(1, 2, 1), Edge(1, 3, 1), Edge(2, 3, 1),
           Edge(2, 4, 1), Edge(3, 4, 1), Edge(4, 5, 1)]
    @test nvertices(g2) == 5
    @test nedgekinds(g2) == 1
    @test nedges(g2) == 6
    @test vertices(g2) == 1:5
    @test edges(g2) == es2
    @test edges_of(g2, 1) == edges(g2)
    @test [indegree_at(g2, v) for v=1:nv] == [0, 1, 2, 2, 1]
    @test [outdegree_at(g2, v) for v=1:nv] == [2, 2, 1, 1, 0]
    @test [degree_at(g2, v) for v=1:nv] == [2, 3, 3, 3, 1]
    @test [inedges_at(g2, v) for v=1:nv] ==
     [Edge[], [Edge(1, 2, 1)], [Edge(1, 3, 1), Edge(2, 3, 1)],
      [Edge(2, 4, 1), Edge(3, 4, 1)], [Edge(4, 5, 1)]]
    @test [outedges_at(g2, v) for v=1:nv] ==
     [[Edge(1, 2, 1), Edge(1, 3, 1)], [Edge(2, 3, 1), Edge(2, 4, 1)],
      [Edge(3, 4, 1)], [Edge(4, 5, 1)], Edge[]]

    # grouped explicitly
    g3 = UGraph(5, [[(1, 2), (1, 3), (2, 4), (3, 4)],  # edges of 1st type
                    [(2, 3), (4, 5)]])                 # edges of 2nd type
    es3 = [Edge(1, 2, 1), Edge(1, 3, 1), Edge(2, 4, 1), Edge(3, 4, 1),
           Edge(2, 3, 2), Edge(4, 5, 2)]
    @test nvertices(g3) == 5
    @test nedgekinds(g3) == 2
    @test nedges(g3) == 6
    @test vertices(g3) == 1:5
    @test edges(g3) == es3
    @test edges_of(g3, 1) == es3[1:4]
    @test edges_of(g3, 2) == es3[5:6]
    @test [indegree_at(g3, v) for v=1:nv] == [0, 1, 2, 2, 1]
    @test [outdegree_at(g3, v) for v=1:nv] == [2, 2, 1, 1, 0]
    @test [degree_at(g3, v) for v=1:nv] == [2, 3, 3, 3, 1]
    @test [inedges_at(g3, v) for v=1:nv] ==
        [Edge[], [Edge(1, 2, 1)], [Edge(1, 3, 1), Edge(2, 3, 2)],
         [Edge(2, 4, 1), Edge(3, 4, 1)], [Edge(4, 5, 2)]]
    @test [outedges_at(g3, v) for v=1:nv] ==
        [[Edge(1, 2, 1), Edge(1, 3, 1)], [Edge(2, 4, 1), Edge(2, 3, 2)],
         [Edge(3, 4, 1)], [Edge(4, 5, 2)], Edge[]]
end


# @testset "UGraph.ToTree" begin
#
#     g1 = ugraph_with_tedges(7,
#         [[(1, 3), (2, 3), (4, 5), (4, 6)], [(3, 4), (6, 7)]])
#     @assert nvertices(g1) == 7
#     @assert nedgetypes(g1) == 2
#     @assert nedges(g1) == 6
#     @assert nedges(g1, 1) == 4
#     @assert nedges(g1, 2) == 2
#
#     t1a = to_tree(g1, 1)
#     @test nvertices(t1a) == 7
#     @test nedgetypes(t1a) == 2
#     @test nedges(t1a) == 6
#     @test [parent(t1a, v) for v in 1:7] == [1, 3, 1, 3, 4, 4, 6]
#     @test [parent_linktype(t1a, v) for v in 1:7] == [0, 1, -1, -2, -1, -1, -2]
#     @test [children(t1a, v) for v in 1:7] ==
#         [[3], Int[], [2,4], [5,6], Int[], [7], Int[]]
#     @test [children_linktypes(t1a, v) for v in 1:7] ==
#         [[1], Int[], [-1,2], [1,1], Int[], [2], Int[]]
#
#     t1b = to_tree(g1, 4)
#     @test nvertices(t1b) == 7
#     @test nedgetypes(t1b) == 2
#     @test nedges(t1b) == 6
#     @test [parent(t1b, v) for v in 1:7] == [3, 3, 4, 4, 4, 4, 6]
#     @test [parent_linktype(t1b, v) for v in 1:7] == [1, 1, 2, 0, -1, -1, -2]
#     @test [children(t1b, v) for v in 1:7] ==
#         [Int[], Int[], [1,2], [3,5,6], Int[], [7], Int[]]
#     @test [children_linktypes(t1b, v) for v in 1:7] ==
#         [Int[], Int[], [-1,-1], [-2,1,1], Int[], [2], Int[]]
#
#     t1c = to_tree(g1, 7)
#     @test nvertices(t1c) == 7
#     @test nedgetypes(t1c) == 2
#     @test nedges(t1c) == 6
#     @test [parent(t1c, v) for v in 1:7] == [3, 3, 4, 6, 4, 7, 7]
#     @test [parent_linktype(t1c, v) for v in 1:7] == [1, 1, 2, 1, -1, 2, 0]
#     @test [children(t1c, v) for v in 1:7] ==
#         [Int[], Int[], [1,2], [3,5], Int[], [4], [6]]
#     @test [children_linktypes(t1c, v) for v in 1:7] ==
#         [Int[], Int[], [-1,-1], [-2,1], Int[], [-1], [-2]]
# end


end # Graphs
