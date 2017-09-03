using Base.Test
using PGM

@testset "JointPMF" begin

@testset "Basics" begin
    p1 = rand(3, 4)
    g1 = JointPMF(["x", "y"], p1)
    @test isa(g1, JointPMF{Float64})
    @test nvars(g1) == 2
    @test vars(g1)[1] == dvar("x", 3)
    @test vars(g1)[2] == dvar("y", 4)
    @test probs(g1) == p1

    p2 = rand(3, 4, 5)
    g2 = JointPMF(("x", "y", "z"), p2)
    @test isa(g2, JointPMF{Float64})
    @test nvars(g2) == 3
    @test vars(g2)[1] == dvar("x", 3)
    @test vars(g2)[2] == dvar("y", 4)
    @test vars(g2)[3] == dvar("z", 5)
    @test probs(g2) == p2
end

@testset "Marginal" begin
    p = rand(3, 4, 5, 2)  # for x, y, z, w
    p ./= sum(p)
    px = reshape(sum(p, (2, 3, 4)), 3)
    py = reshape(sum(p, (1, 3, 4)), 4)
    pz = reshape(sum(p, (1, 2, 4)), 5)
    pw = reshape(sum(p, (1, 2, 3)), 2)

    pxy = reshape(sum(p, (3, 4)), (3, 4))
    pxz = reshape(sum(p, (2, 4)), (3, 5))
    pxw = reshape(sum(p, (2, 3)), (3, 2))
    pyx = pxy.'
    pyz = reshape(sum(p, (1, 4)), (4, 5))
    pyw = reshape(sum(p, (1, 3)), (4, 2))
    pzx = pxz.'
    pzy = pyz.'
    pzw = reshape(sum(p, (1, 2)), (5, 2))
    pwx = pxw.'
    pwy = pyw.'
    pwz = pzw.'

    pxyz = reshape(sum(p, 4), (3, 4, 5))
    pxzy = permutedims(pxyz, (1, 3, 2)); @assert size(pxzy) == (3, 5, 4)
    pyxz = permutedims(pxyz, (2, 1, 3)); @assert size(pyxz) == (4, 3, 5)
    pyzx = permutedims(pxyz, (2, 3, 1)); @assert size(pyzx) == (4, 5, 3)
    pzxy = permutedims(pxyz, (3, 1, 2)); @assert size(pzxy) == (5, 3, 4)
    pzyx = permutedims(pxyz, (3, 2, 1)); @assert size(pzyx) == (5, 4, 3)

    jp1 = JointPMF(("x",), px)
    jp2 = JointPMF(("x", "y"), pxy)
    jp3 = JointPMF(("x", "y", "z"), pxyz)
    jp4 = JointPMF(("x", "y", "z", "w"), p)

    # 1 -> 1
    @test marginal(jp1, "x") == px

    # 2 -> 1
    @test marginal(jp2, "x") ≈ px
    @test marginal(jp2, "y") ≈ py

    # 2 -> 2
    @test marginal(jp2, ("x", "y")) == pxy
    @test marginal(jp2, ("y", "x")) == pyx

    # 3 -> 1
    @test marginal(jp3, "x") ≈ px
    @test marginal(jp3, "y") ≈ py
    @test marginal(jp3, "z") ≈ pz

    # 3 -> 2
    @test marginal(jp3, ("x", "y")) ≈ pxy
    @test marginal(jp3, ("x", "z")) ≈ pxz
    @test marginal(jp3, ("y", "x")) ≈ pyx
    @test marginal(jp3, ("y", "z")) ≈ pyz
    @test marginal(jp3, ("z", "x")) ≈ pzx
    @test marginal(jp3, ("z", "y")) ≈ pzy

    # 3 -> 3
    @test marginal(jp3, ("x", "y", "z")) == pxyz
    @test marginal(jp3, ("x", "z", "y")) == pxzy
    @test marginal(jp3, ("y", "x", "z")) == pyxz
    @test marginal(jp3, ("y", "z", "x")) == pyzx
    @test marginal(jp3, ("z", "x", "y")) == pzxy
    @test marginal(jp3, ("z", "y", "x")) == pzyx

    # 4 -> 1
    @test marginal(jp4, ("x",)) ≈ px
    @test marginal(jp4, ("y",)) ≈ py
    @test marginal(jp4, ("z",)) ≈ pz
    @test marginal(jp4, ("w",)) ≈ pw

    # 4 -> 2
    @test marginal(jp4, ("x", "y")) ≈ pxy
    @test marginal(jp4, ("x", "z")) ≈ pxz
    @test marginal(jp4, ("x", "w")) ≈ pxw
    @test marginal(jp4, ("y", "x")) ≈ pyx
    @test marginal(jp4, ("y", "z")) ≈ pyz
    @test marginal(jp4, ("y", "w")) ≈ pyw
    @test marginal(jp4, ("z", "x")) ≈ pzx
    @test marginal(jp4, ("z", "y")) ≈ pzy
    @test marginal(jp4, ("z", "w")) ≈ pzw
    @test marginal(jp4, ("w", "x")) ≈ pwx
    @test marginal(jp4, ("w", "y")) ≈ pwy
    @test marginal(jp4, ("w", "z")) ≈ pwz

    # 4 -> 3
    @test marginal(jp4, ("x", "y", "z")) ≈ pxyz

    pxwy = sum(p, 3) |>
        r->reshape(r, (3, 4, 2)) |>
        r->permutedims(r, (1, 3, 2))
    @assert size(pxwy) == (3, 2, 4)
    @test marginal(jp4, ("x", "w", "y")) ≈ pxwy

    pwzx = sum(p, 2) |>
        r->reshape(r, (3, 5, 2)) |>
        r->permutedims(r, (3, 2, 1))
    @assert size(pwzx) == (2, 5, 3)
    @test marginal(jp4, ("w", "z", "x")) ≈ pwzx

    pywz = sum(p, 1) |>
        r->reshape(r, (4, 5, 2)) |>
        r->permutedims(r, (1, 3, 2))
    @assert size(pywz) == (4, 2, 5)
    @test marginal(jp4, ("y", "w", "z")) ≈ pywz
end

@testset "Conditional" begin
    p = rand(3, 4, 5)
    p ./= sum(p)
    jp = JointPMF(("x", "y", "z"), p)

    p_x = sum(p, (2, 3))
    p_y = sum(p, (1, 3))
    p_z = sum(p, (1, 2))
    p_xy = sum(p, 3)
    p_xz = sum(p, 2)
    p_yz = sum(p, 1)

    # 1 | 0
    @test conditional(jp, "x", ()) ≈ reshape(p_x, 3)
    @test conditional(jp, "y", ()) ≈ reshape(p_y, 4)
    @test conditional(jp, "z", ()) ≈ reshape(p_z, 5)

    # 2 | 0
    @test conditional(jp, ("x", "y"), ()) ≈ reshape(p_xy, (3, 4))
    @test conditional(jp, ("x", "z"), ()) ≈ reshape(p_xz, (3, 5))
    @test conditional(jp, ("y", "z"), ()) ≈ reshape(p_yz, (4, 5))
    @test conditional(jp, ("z", "x"), ()) ≈ reshape(p_xz, (3, 5)).'

    # 3 | 0
    @test conditional(jp, ("x", "y", "z"), ()) == p
    @test conditional(jp, ("y", "z", "x"), ()) == permutedims(p, (2, 3, 1))

    # 1 | 1
    @test conditional(jp, "x", "y") ≈ reshape(p_xy ./ p_y, (3, 4))
    @test conditional(jp, "x", "z") ≈ reshape(p_xz ./ p_z, (3, 5))
    @test conditional(jp, "y", "x") ≈ reshape(p_xy ./ p_x, (3, 4)).'
    @test conditional(jp, "y", "z") ≈ reshape(p_yz ./ p_z, (4, 5))
    @test conditional(jp, "z", "x") ≈ reshape(p_xz ./ p_x, (3, 5)).'
    @test conditional(jp, "z", "y") ≈ reshape(p_yz ./ p_y, (4, 5)).'

    # 2 | 1
    @test conditional(jp, ("x", "y"), "z") ≈ p ./ p_z
    @test conditional(jp, ("y", "x"), "z") ≈ permutedims(p ./ p_z, (2, 1, 3))
    @test conditional(jp, ("x", "z"), "y") ≈ permutedims(p ./ p_y, (1, 3, 2))
    @test conditional(jp, ("z", "x"), "y") ≈ permutedims(p ./ p_y, (3, 1, 2))
    @test conditional(jp, ("y", "z"), "x") ≈ permutedims(p ./ p_x, (2, 3, 1))
    @test conditional(jp, ("z", "y"), "x") ≈ permutedims(p ./ p_x, (3, 2, 1))

    # 1 | 2
    @test conditional(jp, "x", ("y", "z")) ≈ p ./ p_yz
    @test conditional(jp, "x", ("z", "y")) ≈ permutedims(p ./ p_yz, (1, 3, 2))
    @test conditional(jp, "y", ("x", "z")) ≈ permutedims(p ./ p_xz, (2, 1, 3))
    @test conditional(jp, "y", ("z", "x")) ≈ permutedims(p ./ p_xz, (2, 3, 1))
    @test conditional(jp, "z", ("x", "y")) ≈ permutedims(p ./ p_xy, (3, 1, 2))
    @test conditional(jp, "z", ("y", "x")) ≈ permutedims(p ./ p_xy, (3, 2, 1))
end

end # JointPMF
