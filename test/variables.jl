using Base.Test
using PGM

@testset "Variables" begin

@testset "Var" begin
    dv0 = dvar("dv0", 10)
    @test isa(dv0, Var{0})
    @test dv0.id == "dv0"
    @test vtype(dv0) == intv
    @test cardinality(dv0) == 10
    @test ndims(dv0) == 0
    @test size(dv0) == ()
    @test length(dv0) == 1

    dv1 = dvar("dv1", 10, 3)
    @test isa(dv1, Var{1})
    @test dv1.id == "dv1"
    @test vtype(dv1) == intv
    @test cardinality(dv1) == 10
    @test ndims(dv1) == 1
    @test size(dv1) == (3,)
    @test length(dv1) == 3

    dv2 = dvar("dv2", 10, (3, 4))
    @test isa(dv2, Var{2})
    @test dv2.id == "dv2"
    @test vtype(dv2) == intv
    @test cardinality(dv2) == 10
    @test ndims(dv2) == 2
    @test size(dv2) == (3, 4)
    @test length(dv2) == 12

    rv0 = rvar("rv0")
    @test isa(rv0, Var{0})
    @test rv0.id == "rv0"
    @test vtype(rv0) == realv
    @test cardinality(rv0) == 0
    @test ndims(rv0) == 0
    @test size(rv0) == ()
    @test length(rv0) == 1

    rv1 = rvar("rv1", 3)
    @test isa(rv1, Var{1})
    @test rv1.id == "rv1"
    @test vtype(rv1) == realv
    @test cardinality(rv1) == 0
    @test ndims(rv1) == 1
    @test size(rv1) == (3,)
    @test length(rv1) == 3

    rv2 = rvar("rv2", (3, 4))
    @test isa(rv2, Var{2})
    @test rv2.id == "rv2"
    @test vtype(rv2) == realv
    @test cardinality(rv2) == 0
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
    x = dvar("x", 3)
    y = dvar("y", 4)
    z = dvar("z", 5)
    vl = varlist([x, y, z])

    @test eltype(vl) == SVar
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

    @test_throws KeyError varlist([x, x])
end

end # Variables
