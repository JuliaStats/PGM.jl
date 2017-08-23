using Base.Test
using PGM

@testset "Graphs" begin

@testset "Tree.Basics" begin

    g1 = Tree(7, 2,
              [3, 3, 4, 4, 4, 4, 6],  # parents
              [1, 1, 2, 0, -1, -1, -2])  # parent link-types

    @test nvertices(g1) == 7
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

end # Graphs
