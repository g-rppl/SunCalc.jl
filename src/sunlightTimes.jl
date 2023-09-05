
"""
    getSunlightTimes(
        date::Date, 
        lat::Real,
        lon::Real,
        tz::TimeZone; 
        keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour])

Calculate sunlight times for the given date and location. Return a `NamedTuple` 
    or `DataFrame`.
    
Available variables:

| Variable        | Description                                                              |
| :-------------- | :----------------------------------------------------------------------- |
| `sunrise`       | sunrise (top edge of the sun appears on the horizon)                     |
| `sunriseEnd`    | sunrise ends (bottom edge of the sun touches the horizon)                |
| `goldenHourEnd` | morning golden hour (soft light, best time for photography) ends         |
| `solarNoon`     | solar noon (sun is in the highest position)                              |
| `goldenHour`    | evening golden hour starts                                               |
| `sunsetStart`   | sunset starts (bottom edge of the sun touches the horizon)               |
| `sunset`        | sunset (sun disappears below the horizon, evening civil twilight starts) |
| `dusk`          | dusk (evening nautical twilight starts)                                  |
| `nauticalDusk`  | nautical dusk (evening astronomical twilight starts)                     |
| `night`         | night starts (dark enough for astronomical observations)                 |
| `nadir`         | nadir (darkest moment of the night, sun is in the lowest position)       |
| `nightEnd`      | night ends (morning astronomical twilight starts)                        |
| `nauticalDawn`  | nautical dawn (morning nautical twilight starts)                         |
| `dawn`          | dawn (morning nautical twilight ends, morning civil twilight starts)     |

# Examples
```jldoctest
julia> using Dates, SunCalc
julia> getSunlightTimes(Date(2000, 07, 01), 54, 9; keep=[:sunrise, :sunset])
(sunrise = DateTime("2000-07-01T02:57:50"), sunset = DateTime("2000-07-01T20:00:20"))

julia> using TimeZones
julia> getSunlightTimes(Date(2000, 07, 01), 54, 9, tz"UTC-3"; keep=[:sunrise, :sunset])
(sunrise = ZonedDateTime(2000, 7, 1, 2, 57, 50, tz"UTC-03:00"), 
sunset = ZonedDateTime(2000, 7, 1, 20, 0, 20, tz"UTC-03:00"))

julia> using DataFrames
julia> days = collect(Date(2000,07,01):Day(1):Date(2000,12,31))
julia> getSunlightTimes(days, 54, 9)
184×17 DataFrame
[...]
```	
"""
function getSunlightTimes(
    date::Date,
    lat::Real,
    lon::Real;
    keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour])

    available_var = [:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    data = getTimes(date, lat, lon)

    return data[keep]
end

function getSunlightTimes(
    date::Date,
    lat::Real,
    lon::Real,
    tz::TimeZone;
    keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour])

    available_var = [:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    data = getTimes(date, lat, lon)
    data = map(x -> ismissing(x) ? missing : ZonedDateTime(x, tz), data)

    return data[keep]
end

function getSunlightTimes(
    date::Union{Date,Vector{Date}},
    lat::Union{Real,Vector{<:Real}},
    lon::Union{Real,Vector{<:Real}};
    keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour]
)

    @assert length(lat) == length(lon) "
    Latitude and Longitude must be of equal length."

    if length(lat) > 1
        @assert typeof(date) == Date || length(date) == length(lat) "
        For more than one Location, Date must be either length 1 
        or the same as Latitude/Longitude."
    end

    available_var = [:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    data = DataFrame(date=date, lat=lat, lon=lon)

    times = DataFrame(getTimes.(data.date, data.lat, data.lon))

    data = hcat(data, times[:, keep])

    return data
end

function getSunlightTimes(
    date::Union{Date,Vector{Date}},
    lat::Union{Real,Vector{<:Real}},
    lon::Union{Real,Vector{<:Real}},
    tz::TimeZone;
    keep=[:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour]
)

    available_var = [:solarNoon, :nadir, :sunrise, :sunset, :sunriseEnd,
        :sunsetStart, :dawn, :dusk, :nauticalDawn, :nauticalDusk,
        :nightEnd, :night, :goldenHourEnd, :goldenHour]

    @assert length(lat) == length(lon) "
    Latitude and Longitude must be of equal length."

    if length(lat) > 1
        @assert typeof(date) == Date || length(date) == length(lat) "
        Date must be either length 1 or the same as Latitude/Longitude."
    end

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    data = DataFrame(date=date, lat=lat, lon=lon)

    times = getTimes.(data.date, data.lat, data.lon)
    for i in 1:length(times)
        times[i] = map(x -> ismissing(x) ? missing : ZonedDateTime(x, tz), times[i])
    end
    times = DataFrame(times)

    data = hcat(data, times[:, keep])

    return data
end