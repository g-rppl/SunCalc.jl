using SunCalc
using Test
using Dates
using TimeZones
using DataFrames

@testset "sunlightTimes" begin
    d = Date(2000, 07, 01)

    result = getSunlightTimes(d, 54, 9.0; keep=[:sunrise, :sunset, :night])
    expected = [DateTime(2000, 7, 1, 2, 57, 50), DateTime(2000, 7, 1, 20, 00, 20), missing]
    @test isequal(collect(result), expected)
    @test isa(result,
        NamedTuple{(:sunrise, :sunset, :night),Tuple{DateTime,DateTime,Missing}})

    result = getSunlightTimes(d, 54, 9, tz"UTC"; keep=[:sunrise, :sunset, :night])
    expected = [ZonedDateTime(2000, 7, 1, 2, 57, 50, tz"UTC"),
        ZonedDateTime(2000, 7, 1, 20, 00, 20, tz"UTC"), missing]
    @test isequal(collect(result), expected)
    @test isa(result,
        NamedTuple{(:sunrise, :sunset, :night),Tuple{ZonedDateTime,ZonedDateTime,Missing}})

    result = getSunlightTimes(collect(d:Day(1):Date(2000, 12, 31)), 54, 9)
    @test isa(result, DataFrames.DataFrame)

    result = getSunlightTimes(collect(d:Day(1):Date(2000, 12, 31)), 54, 9, tz"UTC")
    @test isa(result, DataFrames.DataFrame)

    result = getSunlightTimes(d, [54, 55], [9, 10])
    @test nrow(result) == 2
end