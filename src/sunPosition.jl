
"""
    getSunPosition(
        time::Union{DateTime,ZonedDateTime}
        lat::Real,
        lon::Real;
        keep=[:altitude, :azimuth])

Calculate the sun position for the given time and location. Return a `NamedTuple`
    or `DataFrame`.
    
Available variables:

| Variable   | Description                                                                                                                 |
| :--------- | :-------------------------------------------------------------------------------------------------------------------------- |
| `altitude` | Sun altitude above the horizon in radians, e.g. 0 at the horizon and π/2 at the zenith (straight over your head)            |
| `azimuth`  | Sun azimuth in radians (direction along the horizon, measured from south to west), e.g. 0 is south and π * 3/4 is northwest |

# Examples
```julia
using Dates, SunCalc
getSunPosition(DateTime(2000, 07, 01, 12, 00, 00), 54, 9.0)
```	
"""
function getSunPosition(
    time::Union{DateTime,ZonedDateTime},
    lat::Real,
    lon::Real;
    keep=[:altitude, :azimuth])

    available_var = [:altitude, :azimuth]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    if isa(time, ZonedDateTime)
        time = DateTime(time, UTC)
    end

    data = sunPosition(time, lat, lon)

    return data[keep]
end

function getSunPosition(
    time::Union{Vector{DateTime},Vector{ZonedDateTime}},
    lat::Real,
    lon::Real;
    keep=[:altitude, :azimuth])

    available_var = [:altitude, :azimuth]

    @assert all(keep .∈ [available_var]) "
    $(keep[Not(keep .∈ [available_var])]) is not a valid variable."

    time = map(x -> isa(x, ZonedDateTime) ? DateTime(x, UTC) : x, time)

    data = DataFrame(time=time, lat=lat, lon=lon)

    pos = DataFrame(sunPosition.(data.time, data.lat, data.lon))

    data = hcat(data, pos[:, keep])

    return data
end