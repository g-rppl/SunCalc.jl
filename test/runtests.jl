using SunCalc
using Test
using Dates
using TimeZones
using DataFrames

# Example data
t = DateTime(2000, 07, 01, 12, 00, 00)
tz = ZonedDateTime(t + Hour(3), tz"UTC+3")
tt = collect(t:Minute(1):DateTime(2000, 07, 01, 12, 10, 00))
ttz = ZonedDateTime.(tt .+ Hour(3), tz"UTC+3")

d = Date(2000, 07, 01)
dd = collect(d:Day(1):Date(2000, 12, 31))

@testset "sunPosition" begin
    # Single input values
    result = getSunPosition(t, 54, 9.0)
    expected = [1.021444013872015, 0.23904867335099955]
    type = NamedTuple{(:altitude, :azimuth),Tuple{Float64,Float64}}
    @test isequal(collect(result), expected)
    @test isa(result, type)

    result = getSunPosition(t, 54, 9; keep=[:altitude])
    @test isequal(collect(result), [1.021444013872015])
    @test isa(result, NamedTuple{(:altitude,),Tuple{Float64}})

    # Single ZonedDateTime input
    result = getSunPosition(tz, 54, 9)
    @test isequal(collect(result), expected)
    @test isa(result, type)

    # Multiple time inputs
    result = getSunPosition(tt, 54, 9)
    @test isa(result, DataFrames.DataFrame)

    # Multiple ZonedDateTime inputs
    result_tz = getSunPosition(ttz, 54, 9)
    @test isa(result, DataFrames.DataFrame)
    @test isequal(result, result_tz)
end

@testset "sunlightTimes" begin
    # Single input values
    result = getSunlightTimes(d, 54, 9.0)
    expected = [
        DateTime(2000, 07, 01, 11, 29, 05),
        DateTime(2000, 06, 30, 23, 29, 05),
        DateTime(2000, 07, 01, 02, 57, 50),
        DateTime(2000, 07, 01, 20, 00, 20),
        DateTime(2000, 07, 01, 03, 02, 47),
        DateTime(2000, 07, 01, 19, 55, 23),
        DateTime(2000, 07, 01, 02, 04, 14),
        DateTime(2000, 07, 01, 20, 53, 56),
        DateTime(2000, 07, 01, 00, 24, 45),
        DateTime(2000, 07, 01, 22, 33, 25),
        missing,
        missing,
        DateTime(2000, 7, 1, 03, 56, 33),
        DateTime(2000, 7, 1, 19, 01, 37)]
    @test isequal(collect(result), expected)

    result = getSunlightTimes(d, 54, 9, tz"UTC"; keep=[:sunrise, :sunset, :night])
    expected = [
        ZonedDateTime(2000, 7, 1, 2, 57, 50, tz"UTC"),
        ZonedDateTime(2000, 7, 1, 20, 00, 20, tz"UTC"),
        missing]
    @test isequal(collect(result), expected)
    @test isa(
        result,
        NamedTuple{(:sunrise, :sunset, :night),Tuple{ZonedDateTime,ZonedDateTime,Missing}})

    # Multiple location inputs
    result = getSunlightTimes(d, [54, 55], [9, 10])
    @test nrow(result) == 2

    # Multiple date inputs
    result = getSunlightTimes(dd, 54, 9)
    @test isa(result, DataFrames.DataFrame)

    result = getSunlightTimes(dd, 54, 9, tz"UTC")
    @test isa(result, DataFrames.DataFrame)

end

@testset "moonPosition" begin
    # Single input values
    result = getMoonPosition(t, 54, 9.0)
    expected = [
        0.9827239676334404, 0.37053619317956804,
        364261.22074883315, 0.23105612823875385]
    type = NamedTuple{
        (:altitude, :azimuth, :distance, :parallacticAngle),
        Tuple{Float64,Float64,Float64,Float64}}
    @test isequal(collect(result), expected)
    @test isa(result, type)

    result = getMoonPosition(t, 54, 9; keep=[:altitude])
    @test isequal(collect(result), [0.9827239676334404])
    @test isa(result, NamedTuple{(:altitude,),Tuple{Float64}})

    # Single ZonedDateTime input
    result = getMoonPosition(tz, 54, 9)
    @test isequal(collect(result), expected)
    @test isa(result, type)

    # Multiple time inputs
    result = getMoonPosition(tt, 54, 9)
    @test isa(result, DataFrames.DataFrame)

    # Multiple ZonedDateTime inputs
    result_tz = getMoonPosition(ttz, 54, 9)
    @test isa(result, DataFrames.DataFrame)
    @test isequal(result, result_tz)
end

@testset "moonIllumination" begin
    # Single input values
    result = getMoonIllumination(t)
    expected = [0.0016370702592863884, 0.9871174346869234, 1.2446094824748517]
    type = NamedTuple{
        (:fraction, :phase, :angle),
        Tuple{Float64,Float64,Float64}}
    @test isequal(collect(result), expected)
    @test isa(result, type)

    result = getMoonIllumination(Date(t); keep=[:fraction])
    @test isequal(collect(result), [0.009821644145731667])
    @test isa(result, NamedTuple{(:fraction,),Tuple{Float64}})

    # Single ZonedDateTime input
    result = getMoonIllumination(tz)
    @test isequal(collect(result), expected)
    @test isa(result, type)

    # Multiple time inputs
    result = getMoonIllumination(tt)
    @test isa(result, DataFrames.DataFrame)

    # Multiple ZonedDateTime inputs
    result_tz = getMoonIllumination(ttz)
    @test isa(result, DataFrames.DataFrame)
    @test isequal(result, result_tz)
end