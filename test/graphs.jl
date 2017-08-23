using Base.Test
using PGM

@testset "Graphs" begin

@testset "UGraph.Basics" begin

    g1 = simple_ugraph(5, [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (4, 5)])
    @test nvertices(g1) == 5
    @test vertices(g1) == 1:5
    @test nedges(g1) == 6
    @test nedges(g1, 1) == 6
    @test edges(g1, 1) == [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (4, 5)]
    @test [degree(g1, v) for v in 1:5] == [2, 3, 3, 3, 1]
    @test adjlist(g1, 1) == [(2, 1), (3, 1)]
    @test adjlist(g1, 2) == [(1, -1), (3, 1), (4, 1)]
    @test adjlist(g1, 3) == [(1, -1), (2, -1), (4, 1)]
    @test adjlist(g1, 4) == [(2, -1), (3, -1), (5, 1)]
    @test adjlist(g1, 5) == [(4, -1)]

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
     @test adjlist(g2, 1) == [(2, 1), (3, 1)]
     @test adjlist(g2, 2) == [(1, -1), (4, 1), (3, 2)]
     @test adjlist(g2, 3) == [(1, -1), (4, 1), (2, -2)]
     @test adjlist(g2, 4) == [(2, -1), (3, -1), (5, 2)]
     @test adjlist(g2, 5) == [(4, -2)]
end

end # Graphs
