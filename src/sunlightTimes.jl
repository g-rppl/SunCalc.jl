
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
| `sunrise`       | Sunrise (top edge of the sun appears on the horizon)                     |
| `sunriseEnd`    | Sunrise ends (bottom edge of the sun touches the horizon)                |
| `goldenHourEnd` | Morning golden hour (soft light, best time for photography) ends         |
| `solarNoon`     | Solar noon (sun is in the highest position)                              |
| `goldenHour`    | Evening golden hour starts                                               |
| `sunsetStart`   | Sunset starts (bottom edge of the sun touches the horizon)               |
| `sunset`        | Sunset (sun disappears below the horizon, evening civil twilight starts) |
| `dusk`          | Dusk (evening nautical twilight starts)                                  |
| `nauticalDusk`  | Nautical dusk (evening astronomical twilight starts)                     |
| `night`         | Night starts (dark enough for astronomical observations)                 |
| `nadir`         | Nadir (darkest moment of the night, sun is in the lowest position)       |
| `nightEnd`      | Night ends (morning astronomical twilight starts)                        |
| `nauticalDawn`  | Nautical dawn (morning nautical twilight starts)                         |
| `dawn`          | Dawn (morning nautical twilight ends, morning civil twilight starts)     |

# Examples
```julia
using Dates, SunCalc
getSunlightTimes(Date(2000, 07, 01), 54, 9; keep=[:sunrise, :sunset])

using TimeZones
getSunlightTimes(Date(2000, 07, 01), 54, 9, tz"UTC-3"; keep=[:sunrise, :sunset])

using DataFrames
days = collect(Date(2000, 07, 01):Day(1):Date(2000, 12, 31))
getSunlightTimes(days, 54, 9)
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