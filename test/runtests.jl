using SunCalc
using Test
using Dates
using TimeZones
using DataFrames

@testset "sunlightTimes" begin
    # Single input values
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

    # Multiple location inputs
    result = getSunlightTimes(d, [54, 55], [9, 10])
    @test nrow(result) == 2

    # Multiple date inputs
    d = collect(d:Day(1):Date(2000, 12, 31))

    result = getSunlightTimes(d, 54, 9)
    @test isa(result, DataFrames.DataFrame)

    result = getSunlightTimes(d, 54, 9, tz"UTC")
    @test isa(result, DataFrames.DataFrame)

end

@testset "sunPosition" begin
    # Single input values
    t = DateTime(2000, 07, 01, 12, 00, 00)

    result = getSunPosition(t, 54, 9.0)
    expected = [1.021444013872015, 0.23904867335099955]
    @test isequal(collect(result), expected)
    @test isa(result, NamedTuple{(:altitude, :azimuth),Tuple{Float64,Float64}})

    result = getSunPosition(t, 54, 9; keep=[:altitude])
    @test isequal(collect(result), [1.021444013872015])
    @test isa(result, NamedTuple{(:altitude,),Tuple{Float64}})

    # Single ZonedDateTime input
    tz = ZonedDateTime(t, tz"UTC+3")

    result = getSunPosition(tz, 54, 9)
    expected = [0.8441554042091998, -0.9947216075637547]
    @test isequal(collect(result), expected)
    @test isa(result, NamedTuple{(:altitude, :azimuth),Tuple{Float64,Float64}})

    # Multiple time inputs
    t = collect(t:Minute(1):DateTime(2000, 07, 01, 12, 10, 00))

    result = getSunPosition(t, 54, 9)
    @test isa(result, DataFrames.DataFrame)

    # Multiple ZonedDateTime inputs
    tz = ZonedDateTime.(t, tz"UTC+3")
    result = getSunPosition(t, 54, 9)
    @test isa(result, DataFrames.DataFrame)
end