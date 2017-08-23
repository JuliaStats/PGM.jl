using Base.Test
using PGM

@testset "DMRF" begin

@testset "DPMRF.Basics" begin

    vlst = VarList([dvar("x1", 1:3),
                    dvar("x2", 1:3),
                    dvar("x3", 1:2),
                    dvar("x4", 1:2),
                    dvar("x5", 1:3),
                    dvar("x6", 1:3)])
    elists = [[(1, 2), (5, 6)],
              [(3, 4)],
              [(1, 3), (2, 4), (5, 3), (6, 4)]]
    gr = ugraph_with_tedges(6, elists)
    mrf0 = DiscretePairwiseMRF{Float64}(vlst, gr)

    @test nvars(mrf0) == 6
    @test nvertices(mrf0) == 6
    @test nedgetypes(mrf0) == 3
    @test nedges(mrf0) == 7
    @test [edges(mrf0, t) for t in 1:3] == elists
    @test vars(mrf0) === vlst
    @test [var_cardinalities(mrf0, t) for t in 1:6] == [3, 3, 2, 2, 3, 3]
    @test [edge_pdims(mrf0, t) for t in 1:3] == [(3, 3), (2, 2), (3, 2)]
    @test !has_vertex_potentials(mrf0)
    @test !has_edge_potentials(mrf0)

    vpots = [floor.(rand(d) * 100) for d in [3, 3, 2, 2, 3, 3]]
    epots = [floor.(rand(d1, d2) * 100) for (d1, d2) in [(3, 3), (2, 2), (3, 2)]]

    mrf1 = pwmrf(vlst, gr, vpots, epots)
    @test nvars(mrf1) == 6
    @test nvertices(mrf1) == 6
    @test nedgetypes(mrf1) == 3
    @test nedges(mrf1) == 7
    @test [var_cardinalities(mrf1, t) for t in 1:6] == [3, 3, 2, 2, 3, 3]
    @test [edge_pdims(mrf1, t) for t in 1:3] == [(3, 3), (2, 2), (3, 2)]
    @test has_vertex_potentials(mrf1)
    @test has_edge_potentials(mrf1)
    @test vertex_potentials(mrf1) === vpots
    @test edge_potentials(mrf1) === epots
end


end # DMRF
