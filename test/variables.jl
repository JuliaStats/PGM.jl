using Base.Test
using PGM

@testset "ValueSpace" begin
    @test RealSpace <: ValueSpace
    @test FiniteSpace <: ValueSpace
    @test RangeSpace <: FiniteSpace

    @test RealSpace() == RealSpace()
    @test !(RealSpace() != RealSpace())
    @test string(RealSpace()) == "RealSpace"

    rgn_space = RangeSpace(2:8)
    @test values(rgn_space) == 2:8
    @test length(rgn_space) == 7
    @test rgn_space == rgn_space
    @test !(rgn_space != rgn_space)
    @test rgn_space != RealSpace()
    @test rgn_space != RangeSpace(1:10)
    @test string(rgn_space) == "RangeSpace(2:8)"

    @test indexof(2, rgn_space) == 1
    @test indexof(5, rgn_space) == 4
    @test indexof(8, rgn_space) == 7
    @test_throws ArgumentError indexof(1, rgn_space)
    @test_throws ArgumentError indexof(9, rgn_space)
end

@testset "Var" begin
    dv0 = dvar("dv0", 1:10)
    @test isa(dv0, DVar{0})
    @test dv0.id == "dv0"
    @test dv0.space == RangeSpace(1:10)
    @test ndims(dv0) == 0
    @test size(dv0) == ()
    @test length(dv0) == 1

    dv1 = dvar("dv1", 1:10, 3)
    @test isa(dv1, DVar{1})
    @test dv1.id == "dv1"
    @test dv1.space == RangeSpace(1:10)
    @test ndims(dv1) == 1
    @test size(dv1) == (3,)
    @test length(dv1) == 3

    dv2 = dvar("dv2", 1:10, (3, 4))
    @test isa(dv2, DVar{2})
    @test dv2.id == "dv2"
    @test dv2.space == RangeSpace(1:10)
    @test ndims(dv2) == 2
    @test size(dv2) == (3, 4)
    @test length(dv2) == 12

    rv0 = rvar("rv0")
    @test isa(rv0, RVar{0})
    @test rv0.id == "rv0"
    @test rv0.space == RealSpace()
    @test ndims(rv0) == 0
    @test size(rv0) == ()
    @test length(rv0) == 1

    rv1 = rvar("rv1", 3)
    @test isa(rv1, RVar{1})
    @test rv1.id == "rv1"
    @test rv1.space == RealSpace()
    @test ndims(rv1) == 1
    @test size(rv1) == (3,)
    @test length(rv1) == 3

    rv2 = rvar("rv2", (3, 4))
    @test isa(rv2, RVar{2})
    @test rv2.id == "rv2"
    @test rv2.space == RealSpace()
    @test ndims(rv2) == 2
    @test size(rv2) == (3, 4)
    @test length(rv2) == 12

    @test dv1 == dv1
    @test !(dv1 != dv1)
    @test dv1 != dv2
    @test !(dv1 == dv2)
    @test rv1 == rv1
    @test rv1 != rv2
    @test dv1 != rv1
    @test !(dv1 == rv1)
end

@testset "VarList" begin
    x = dvar("x", 1:3)
    y = dvar("y", 1:4)
    z = dvar("z", 1:5)
    vl = VarList([x, y, z])

    @test eltype(vl) == DVar{0}
    @test ndims(vl) == 1
    @test length(vl) == 3
    @test size(vl) == (3,)
    @test collect(vl) == [x, y, z]
    @test collect(eachindex(vl)) == [1, 2, 3]

    @test vl[1] == x
    @test vl[2] == y
    @test vl[3] == z
    @test vl["x"] == x
    @test vl["y"] == y
    @test vl["z"] == z

    @test indexof("x", vl) == 1
    @test indexof("y", vl) == 2
    @test indexof("z", vl) == 3
    @test_throws KeyError indexof("a", vl)
    @test indexof(("z", "x"), vl) == [3, 1]

    @test_throws KeyError VarList([x, x])
end
