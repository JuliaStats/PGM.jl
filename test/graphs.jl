using Base.Test
using PGM

@testset "Graphs" begin

@testset "Tree.Basics" begin

    g1 = Tree(7, 2,
              [3, 3, 4, 4, 4, 4, 6],  # parents
              [1, 1, 2, 0, -1, -1, -2])  # parent link-types

    @test nvertices(g1) == 7
    @test nedgetypes(g1) == 2
    @test nedges(g1) == 6

    @test [parent(g1, v) for v in 1:7] == [3, 3, 4, 4, 4, 4, 6]
    @test [parent_linktype(g1, v) for v in 1:7] == [1, 1, 2, 0, -1, -1, -2]
    @test [children(g1, v) for v in 1:7] ==
        [Int[], Int[], [1,2], [3,5,6], Int[], [7], Int[]]
    @test [children_linktypes(g1, v) for v in 1:7] ==
        [Int[], Int[], [-1,-1], [-2,1,1], Int[], [2], Int[]]
    @test [degree(g1, v) for v in 1:7] == [1, 1, 3, 3, 1, 2, 1]

    @test root(g1) == 4
    @test [Int(isroot(g1, v)) for v in 1:7] == [0, 0, 0, 1, 0, 0, 0]
    @test [Int(isleaf(g1, v)) for v in 1:7] == [1, 1, 0, 0, 1, 0, 1]
end


@testset "UGraph.Basics" begin

    g1 = simple_ugraph(5, [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (4, 5)])
    @test nvertices(g1) == 5
    @test vertices(g1) == 1:5
    @test nedgetypes(g1) == 1
    @test nedges(g1) == 6
    @test nedges(g1, 1) == 6
    @test edges(g1, 1) == [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (4, 5)]
    @test [degree(g1, v) for v in 1:5] == [2, 3, 3, 3, 1]
    @test [neighbors(g1, v) for v in 1:5] ==
        [[2,3], [1,3,4], [1,2,4], [2,3,5], [4]]
    @test [neighbor_linktypes(g1, v) for v in 1:5] ==
        [[1,1], [-1,1,1], [-1,-1,1], [-1,-1,1], [-1]]

    g2 = ugraph_with_tedges(5,              # number of vertices
        [[(1, 2), (1, 3), (2, 4), (3, 4)],  # edges of 1st type
         [(2, 3), (4, 5)]])                 # edges of 2nd type
    @test nvertices(g2) == 5
    @test vertices(g2) == 1:5
    @test nedgetypes(g2) == 2
    @test nedges(g2) == 6
    @test nedges(g2, 1) == 4
    @test nedges(g2, 2) == 2
    @test edges(g2, 1) == [(1, 2), (1, 3), (2, 4), (3, 4)]
    @test edges(g2, 2) == [(2, 3), (4, 5)]
    @test [degree(g2, v) for v in 1:5] == [2, 3, 3, 3, 1]
    @test [neighbors(g2, v) for v in 1:5] ==
        [[2,3], [1,4,3], [1,4,2], [2,3,5], [4]]
    @test [neighbor_linktypes(g2, v) for v in 1:5] ==
        [[1,1], [-1,1,2], [-1,1,-2], [-1,-1,2], [-2]]
end


@testset "UGraph.ToTree" begin

    g1 = ugraph_with_tedges(7,
        [[(1, 3), (2, 3), (4, 5), (4, 6)], [(3, 4), (6, 7)]])
    @assert nvertices(g1) == 7
    @assert nedgetypes(g1) == 2
    @assert nedges(g1) == 6
    @assert nedges(g1, 1) == 4
    @assert nedges(g1, 2) == 2

    t1a = to_tree(g1, 1)
    @test nvertices(t1a) == 7
    @test nedgetypes(t1a) == 2
    @test nedges(t1a) == 6
    @test [parent(t1a, v) for v in 1:7] == [1, 3, 1, 3, 4, 4, 6]
    @test [parent_linktype(t1a, v) for v in 1:7] == [0, 1, -1, -2, -1, -1, -2]
    @test [children(t1a, v) for v in 1:7] ==
        [[3], Int[], [2,4], [5,6], Int[], [7], Int[]]
    @test [children_linktypes(t1a, v) for v in 1:7] ==
        [[1], Int[], [-1,2], [1,1], Int[], [2], Int[]]

    t1b = to_tree(g1, 4)
    @test nvertices(t1b) == 7
    @test nedgetypes(t1b) == 2
    @test nedges(t1b) == 6
    @test [parent(t1b, v) for v in 1:7] == [3, 3, 4, 4, 4, 4, 6]
    @test [parent_linktype(t1b, v) for v in 1:7] == [1, 1, 2, 0, -1, -1, -2]
    @test [children(t1b, v) for v in 1:7] ==
        [Int[], Int[], [1,2], [3,5,6], Int[], [7], Int[]]
    @test [children_linktypes(t1b, v) for v in 1:7] ==
        [Int[], Int[], [-1,-1], [-2,1,1], Int[], [2], Int[]]

    t1c = to_tree(g1, 7)
    @test nvertices(t1c) == 7
    @test nedgetypes(t1c) == 2
    @test nedges(t1c) == 6
    @test [parent(t1c, v) for v in 1:7] == [3, 3, 4, 6, 4, 7, 7]
    @test [parent_linktype(t1c, v) for v in 1:7] == [1, 1, 2, 1, -1, 2, 0]
    @test [children(t1c, v) for v in 1:7] ==
        [Int[], Int[], [1,2], [3,5], Int[], [4], [6]]
    @test [children_linktypes(t1c, v) for v in 1:7] ==
        [Int[], Int[], [-1,-1], [-2,1], Int[], [-1], [-2]]
end


end # Graphs
