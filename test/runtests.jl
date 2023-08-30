using suncalc
using Test
using Dates
using TimeZones
using DataFrames

@testset "sunlightTimes" begin
    d = Date(2000, 01, 01)

    result = getSunlightTimes(d, 54, 9; keep=[:sunrise, :sunset])
    expected = [DateTime(2000, 1, 1, 7, 44, 15), DateTime(2000, 1, 1, 15, 12, 42)]
    @test collect(result) == expected
    @test typeof(result) == NamedTuple{(:sunrise, :sunset),
    Tuple{DateTime,DateTime}}

    result = getSunlightTimes(d, 54.0, 9.0; keep=[:sunrise, :sunset])
    @test collect(result) == expected
    @test typeof(result) == NamedTuple{(:sunrise, :sunset),
        Tuple{DateTime,DateTime}}
    
    result = getSunlightTimes(d, 54, 9, tz"UTC"; keep=[:sunrise, :sunset])
    expected = [ZonedDateTime(2000, 1, 1, 7, 44, 15, tz"UTC"),
        ZonedDateTime(2000, 1, 1, 15, 12, 42, tz"UTC")]
    @test collect(result) == expected
    @test typeof(result) == NamedTuple{(:sunrise, :sunset),
        Tuple{ZonedDateTime,ZonedDateTime}}

    result = getSunlightTimes(collect(d:Day(1):Date(2000, 12, 31)), 54, 9)
    @test typeof(result) == DataFrames.DataFrame

    result = getSunlightTimes(collect(d:Day(1):Date(2000, 12, 31)), 54, 9, tz"UTC")
    @test typeof(result) == DataFrames.DataFrame

    result = getSunlightTimes(d, [54, 55], [9, 10])
    @test nrow(result) == 2
end