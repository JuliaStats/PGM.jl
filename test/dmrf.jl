using Base.Test
using PGM

@testset "DMRF" begin

@testset "DPMRF.Basics" begin

    vlst = VarList([dvar("x1", 3),
                    dvar("x2", 3),
                    dvar("x3", 2),
                    dvar("x4", 2),
                    dvar("x5", 3),
                    dvar("x6", 3)])
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


function collect_tpotentials(mrf::DiscretePairwiseMRF)
    r = zeros(mrf.cards...)
    for ci in Base.CartesianRange(size(r))
        r[ci] = tpotential(mrf, collect(ci.I))
    end
    r
end


@testset "DPMRF.Potentials" begin

    vlst = VarList([dvar("x1", 3),
                    dvar("x2", 3),
                    dvar("x3", 2),
                    dvar("x4", 2),
                    dvar("x5", 3),
                    dvar("x6", 3)])
    elists = [[(1, 2), (5, 6)],
              [(3, 4)],
              [(1, 3), (2, 4), (5, 3), (6, 4)]]
    gr = ugraph_with_tedges(6, elists)
    mrf = DiscretePairwiseMRF{Float64}(vlst, gr)

    r0_a = collect_tpotentials(mrf)
    r0_b = tpotentials(mrf)

    z = zeros(3, 3, 2, 2, 3, 3)
    @test r0_a == z
    @test r0_b == z

    vpots = [floor.(rand(d) * 100) for d in [3, 3, 2, 2, 3, 3]]
    epots = [floor.(rand(d1, d2) * 100) for (d1, d2) in [(3, 3), (2, 2), (3, 2)]]
    set_vertex_potentials!(mrf, vpots)
    set_edge_potentials!(mrf, epots)

    vp1, vp2, vp3, vp4, vp5, vp6 = vpots
    ep1, ep2, ep3 = epots

    s1 = [1, 1, 1, 1, 1, 1]
    p1 = vp1[1] + vp2[1] + vp3[1] + vp4[1] + vp5[1] + vp6[1] +
         ep1[1,1] * 2 + ep2[1,1] + ep3[1,1] * 4
    @test tpotential(mrf, s1) == p1

    s2 = [2, 1, 1, 2, 3, 2]
    p2 = vp1[2] + vp2[1] + vp3[1] + vp4[2] + vp5[3] + vp6[2] +
         ep1[2,1] + ep1[3,2] + ep2[1,2] + ep3[2,1] + ep3[1,2] + ep3[3,1] + ep3[2,2]
    @test tpotential(mrf, s2) == p2

    r1_a = collect_tpotentials(mrf)
    r1_b = tpotentials(mrf)
    @test r1_a == r1_b
end


end # DMRF
