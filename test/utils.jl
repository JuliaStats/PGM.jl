using Base.Test
using PGM
using Combinatorics

@testset "Utils" begin

@testset "range_rm" begin
    @test PGM.Utils.range_rm(1, 1) == Int[]
    @test PGM.Utils.range_rm(2, 1) == [2]
    @test PGM.Utils.range_rm(2, 2) == [1]
    @test PGM.Utils.range_rm(5, 1) == [2, 3, 4, 5]
    @test PGM.Utils.range_rm(5, 3) == [1, 2, 4, 5]
    @test PGM.Utils.range_rm(5, 5) == [1, 2, 3, 4]

    @test PGM.Utils.range_rm(1, [1]) == Int[]
    @test PGM.Utils.range_rm(2, [1]) == [2]
    @test PGM.Utils.range_rm(2, [2]) == [1]
    @test PGM.Utils.range_rm(2, []) == [1, 2]
    @test PGM.Utils.range_rm(2, [1,2]) == Int[]
    @test PGM.Utils.range_rm(5, [1]) == [2, 3, 4, 5]
    @test PGM.Utils.range_rm(5, [3]) == [1, 2, 4, 5]
    @test PGM.Utils.range_rm(5, [5]) == [1, 2, 3, 4]
    @test PGM.Utils.range_rm(5, [1, 3]) == [2, 4, 5]
    @test PGM.Utils.range_rm(5, [3, 5]) == [1, 2, 4]
    @test PGM.Utils.range_rm(5, [1, 5]) == [2, 3, 4]
    @test PGM.Utils.range_rm(5, 1:4) == [5]
    @test PGM.Utils.range_rm(5, 2:5) == [1]
    @test PGM.Utils.range_rm(5, 1:5) == Int[]
end

@testset "isortperm" begin
    for p in permutations(1:3)
        @test PGM.Utils.isortperm(p + 2) == p
    end

    for p in permutations(1:4)
        @test PGM.Utils.isortperm(p + 2) == p
    end

    for p in permutations(1:5)
        @test PGM.Utils.isortperm(p + 2) == p
    end
end

end  # Utils
