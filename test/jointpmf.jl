using Base.Test
using PGM

@testset "JointPMF.Basics" begin
    p1 = rand(3, 4)
    g1 = JointPMF(["x", "y"], p1)
    @test isa(g1, JointPMF{Float64})
    @test nvars(g1) == 2
    @test vars(g1)[1] == dvar("x", 1:3)
    @test vars(g1)[2] == dvar("y", 1:4)
    @test probs(g1) == p1

    p2 = rand(3, 4, 5)
    g2 = JointPMF(("x", "y", "z"), p2)
    @test isa(g2, JointPMF{Float64})
    @test nvars(g2) == 3
    @test vars(g2)[1] == dvar("x", 1:3)
    @test vars(g2)[2] == dvar("y", 1:4)
    @test vars(g2)[3] == dvar("z", 1:5)
    @test probs(g2) == p2
end
