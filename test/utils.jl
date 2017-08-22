using Base.Test
using PGM

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

end
