using Base.Test
using PGM


struct NameV
    id::String
    v::Int
end


@testset "Lists" begin

@testset "GroupedList" begin

    gl0 = grlist_from_counts(String[], [0])
    @test eltype(gl0) == String
    @test length(gl0) == 0
    @test ngroups(gl0) == 1
    @test group_length(gl0, 1) == 0
    @test collect(group(gl0, 1)) == String[]

    gl1 = grlist_from_counts(["a", "b", "c", "d", "e", "f"], [2, 1, 0, 3])
    @test eltype(gl1) == String
    @test length(gl1) == 6
    @test ngroups(gl1) == 4
    @test [group_length(gl1, k) for k = 1:4] == [2, 1, 0, 3]
    @test collect(group(gl1, 1)) == ["a", "b"]
    @test collect(group(gl1, 2)) == ["c"]
    @test collect(group(gl1, 3)) == String[]
    @test collect(group(gl1, 4)) == ["d", "e", "f"]
end

@testset "NamedList" begin

    e1 = NameV("a", 12)
    e2 = NameV("x", 23)
    e3 = NameV("c", 36)

    nl1 = namedlist([e1, e2, e3], e -> e.id)
    @test eltype(nl1) == NameV
    @test ndims(nl1) == 1
    @test length(nl1) == 3
    @test size(nl1) == (3,)
    @test collect(nl1) == [e1, e2, e3]
    @test collect(eachindex(nl1)) == [1, 2, 3]

    @test nl1[1] == e1
    @test nl1[2] == e2
    @test nl1[3] == e3
    @test nl1["a"] == e1
    @test nl1["x"] == e2
    @test nl1["c"] == e3

    @test indexof("a", nl1) == 1
    @test indexof("x", nl1) == 2
    @test indexof("c", nl1) == 3
    @test indexof(("c", "a"), nl1) == [3, 1]
    @test_throws KeyError indexof("b", nl1)
    @test_throws KeyError namedlist([e1, e1], e -> e.id)

    nl2 = namedlist_from_pairs([("a", 12), ("x", 23), ("c", 36)])
    @test eltype(nl2) == Int
    @test ndims(nl2) == 1
    @test length(nl2) == 3
    @test size(nl2) == (3,)
    @test collect(nl2) == [12, 23, 36]
    @test collect(eachindex(nl2)) == [1, 2, 3]

    @test nl2[1] == 12
    @test nl2[2] == 23
    @test nl2[3] == 36
    @test nl2["a"] == 12
    @test nl2["x"] == 23
    @test nl2["c"] == 36
end

end  # Lists
